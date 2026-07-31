from fastapi import HTTPException
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from app.models.user import User
from app.models.ask import Ask
from app.schemas.ask import AskCreate, AskResponse, ReplyCreate, ReplyResponse
from app.repositories import ask_repository as ask_repo
from app.repositories import reply_repository as reply_repo
from app.repositories import friend_repository as friend_repo
from app.services import notification_service
from app.repositories import activity_repository as act_repo
from app.core.event_publisher import event_publisher
from app.core.ws_manager import manager
from app.core.config import settings

def utc_now():
    return datetime.now(timezone.utc)

def map_ask_to_response(ask: Ask, user: User) -> AskResponse:
    return AskResponse(
        id=str(ask.id),
        requester_id=str(user.id),
        requester_name=user.display_name,
        requester_image=user.profile_picture,
        title=ask.title,
        description=ask.description,
        category=ask.category,
        location=ask.location,
        status=ask.status,
        reply_count=ask.reply_count,
        max_replies=ask.max_replies,
        created_at=ask.created_at.isoformat(),
        expires_at=ask.expires_at.isoformat()
    )

async def create_ask(req: AskCreate, current_user: User) -> AskResponse:
    expires_at = utc_now() + timedelta(minutes=req.expires_in_minutes)
    
    ask = Ask(
        requester_id=str(current_user.id),
        title=req.title,
        description=req.description,
        category=req.category,
        location=req.location,
        expires_at=expires_at
    )
    
    ask = await ask_repo.create(ask)
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="ASK_CREATED",
        metadata={"ask_id": str(ask.id)}
    )
    
    await event_publisher.publish_ask_created(str(ask.id), str(current_user.id), ask.dict())
    
    # Broadcast to public dashboard (anonymized)
    public_ask = map_ask_to_response(ask, current_user).model_dump()
    public_ask["requester_name"] = f"Student near {ask.location}"
    public_ask["requester_image"] = "/static/default.png"
    public_ask["requester_id"] = "anonymous"
    await manager.broadcast_public("ASK_CREATED", public_ask)
    
    return map_ask_to_response(ask, current_user)

async def list_feed(current_user: User, skip: int = 0, limit: int = 20) -> List[AskResponse]:
    # Get all friends
    friendships = await friend_repo.list_friends(str(current_user.id))
    friend_ids = []
    for f in friendships:
        friend_ids.append(f.user2 if f.user1 == str(current_user.id) else f.user1)
        
    if not friend_ids:
        return []
        
    asks = await ask_repo.find_feed(friend_ids, skip, limit)
    
    response = []
    # Fetch user details for each ask. In a real scenario, this could be optimized with a join or dataloader.
    user_cache = {}
    for ask in asks:
        if ask.requester_id not in user_cache:
            user = await friend_repo.find_user_by_id(ask.requester_id)
            user_cache[ask.requester_id] = user
        
        user = user_cache[ask.requester_id]
        if user:
            response.append(map_ask_to_response(ask, user))
            
    return response

async def list_my_asks(current_user: User, skip: int = 0, limit: int = 20) -> List[AskResponse]:
    asks = await ask_repo.find_my_asks(str(current_user.id), skip, limit)
    return [map_ask_to_response(ask, current_user) for ask in asks]

async def get_ask(ask_id: str, current_user: User) -> AskResponse:
    ask = await ask_repo.find_by_id(ask_id)
    if not ask or not ask.is_active:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    if ask.requester_id != str(current_user.id):
        # Verify they are friends
        if not await friend_repo.are_friends(str(current_user.id), ask.requester_id):
            raise HTTPException(status_code=403, detail="Not authorized to view this ask")
            
    requester = await friend_repo.find_user_by_id(ask.requester_id)
    return map_ask_to_response(ask, requester)

async def reply_to_ask(ask_id: str, req: ReplyCreate, current_user: User):
    ask = await ask_repo.find_by_id(ask_id)
    if not ask or not ask.is_active:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    if ask.requester_id == str(current_user.id):
        raise HTTPException(status_code=400, detail="Cannot reply to your own ask")
        
    if not await friend_repo.are_friends(str(current_user.id), ask.requester_id):
        raise HTTPException(status_code=403, detail="Only friends can reply")
        
    existing_reply = await reply_repo.find_reply_by_user_and_ask(ask_id, str(current_user.id))
    if existing_reply:
        raise HTTPException(status_code=400, detail="You have already replied to this ask")
        
    # ATOMIC LOCK
    new_count = await ask_repo.atomic_increment_and_lock(ask_id)
    if new_count == -1:
        raise HTTPException(status_code=409, detail="Ask is no longer open or has reached max replies")
        
    # Calculate ETA if provided
    estimated_arrival_time = None
    if req.arrival_eta_minutes is not None:
        estimated_arrival_time = utc_now() + timedelta(minutes=req.arrival_eta_minutes)

    # Insert Reply
    reply = await reply_repo.create_reply(
        ask_id=ask_id, 
        responder_id=str(current_user.id), 
        message=req.message,
        arrival_eta_minutes=req.arrival_eta_minutes,
        estimated_arrival_time=estimated_arrival_time
    )
    
    await event_publisher.publish_reply_created(ask_id, str(reply.id), str(current_user.id))
    
    await notification_service.create_notification(
        user_id=ask.requester_id,
        title="New Reply",
        message=f"{current_user.display_name} replied to your ask: {ask.title}",
        type="REPLY_RECEIVED",
        sender_avatar=current_user.profile_picture
    )
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="REPLY_CREATED",
        metadata={"ask_id": ask_id, "reply_id": str(reply.id)}
    )
    
    await manager.broadcast_public("REPLY_ADDED", {"ask_id": ask_id})
    
    if new_count >= ask.max_replies:
        await event_publisher.publish_ask_locked(ask_id)
        await notification_service.create_notification(
            user_id=ask.requester_id,
            title="Ask Locked",
            message=f"Your ask '{ask.title}' has reached the maximum number of replies and is now locked.",
            type="ASK_LOCKED",
            sender_avatar=""  # System notification, no specific sender
        )
        await act_repo.create_activity_log(
            user_id=ask.requester_id,
            action="ASK_LOCKED",
            metadata={"ask_id": ask_id}
        )
        
        await manager.broadcast_public("ASK_LOCKED", {"ask_id": ask_id})
        
    return {"status": "success", "message": "Reply added successfully"}

async def list_replies(ask_id: str, current_user: User) -> List[ReplyResponse]:
    ask = await ask_repo.find_by_id(ask_id)
    if not ask or not ask.is_active:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    if ask.requester_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Only the requester can view all replies")
        
    replies = await reply_repo.list_replies_for_ask(ask_id)
    response = []
    user_cache = {}
    
    for r in replies:
        if r.responder_id not in user_cache:
            user = await friend_repo.find_user_by_id(r.responder_id)
            user_cache[r.responder_id] = user
            
        user = user_cache[r.responder_id]
        if user:
            response.append(ReplyResponse(
                id=str(r.id),
                ask_id=r.ask_id,
                responder_id=r.responder_id,
                responder_name=user.display_name,
                responder_image=user.profile_picture,
                message=r.message,
                arrival_eta_minutes=r.arrival_eta_minutes,
                estimated_arrival_time=r.estimated_arrival_time.isoformat() if r.estimated_arrival_time else None,
                created_at=r.created_at.isoformat()
            ))
            
    return response

async def resolve_ask(ask_id: str, reply_id: str, current_user: User):
    ask = await ask_repo.find_by_id(ask_id)
    if not ask or not ask.is_active:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    if ask.requester_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to resolve this ask")
        
    if ask.status not in ["OPEN", "LOCKED"]:
        raise HTTPException(status_code=400, detail=f"Cannot resolve ask in {ask.status} state")
        
    success = await ask_repo.resolve(ask_id, reply_id)
    if not success:
        raise HTTPException(status_code=400, detail="Failed to resolve ask")
        
    await event_publisher.publish_ask_resolved(ask_id, reply_id)
    
    # Notify the helper
    reply = await reply_repo.find_reply_by_id(reply_id)
    if reply:
        await notification_service.create_notification(
            user_id=reply.responder_id,
            title="Ask Resolved",
            message=f"Your reply to '{ask.title}' was accepted! Ask is resolved.",
            type="ASK_RESOLVED",
            sender_avatar=current_user.profile_picture
        )
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="ASK_RESOLVED",
        metadata={"ask_id": ask_id, "reply_id": reply_id}
    )
    
    await manager.broadcast_public("ASK_RESOLVED", {"ask_id": ask_id})
    
    return {"status": "success", "message": "Ask resolved"}

async def delete_ask(ask_id: str, current_user: User):
    ask = await ask_repo.find_by_id(ask_id)
    if not ask or not ask.is_active:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    if ask.requester_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to delete this ask")
        
    success = await ask_repo.soft_delete(ask_id)
    if not success:
        raise HTTPException(status_code=400, detail="Failed to delete ask")
        
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="ASK_DELETED",
        metadata={"ask_id": ask_id}
    )
    
    return {"status": "success", "message": "Ask deleted"}
