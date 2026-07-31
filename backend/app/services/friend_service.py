from fastapi import HTTPException, status
from typing import List
from app.models.user import User
from app.schemas.friend import (
    UserSearchResponse, FriendRequestCreate, FriendRequestAction,
    PendingRequestResponse, FriendResponse
)
from app.repositories import friend_repository as friend_repo
from app.services import notification_service
from app.repositories import activity_repository as act_repo

async def search_users(query: str, current_user: User) -> List[UserSearchResponse]:
    if not query:
        return []
    users = await friend_repo.search_users(query, str(current_user.id))
    
    current_user_id = str(current_user.id)
    response = []
    for u in users:
        target_id = str(u.id)
        status = "NONE"
        if await friend_repo.are_friends(current_user_id, target_id):
            status = "FRIENDS"
        elif await friend_repo.get_pending_request(current_user_id, target_id):
            status = "PENDING_SENT"
        elif await friend_repo.get_pending_request(target_id, current_user_id):
            status = "PENDING_RECEIVED"
            
        response.append(UserSearchResponse(
            id=target_id,
            username=u.username,
            display_name=u.display_name,
            profile_image=u.profile_picture,
            status=u.status,
            friendship_status=status
        ))
    return response

async def send_friend_request(req: FriendRequestCreate, current_user: User):
    if req.username == current_user.username:
        raise HTTPException(status_code=400, detail="Cannot send request to yourself")
    
    receiver = await friend_repo.find_user_by_username(req.username)
    if not receiver:
        raise HTTPException(status_code=404, detail="User not found")
        
    sender_id = str(current_user.id)
    receiver_id = str(receiver.id)
    
    # Check if already friends
    if await friend_repo.are_friends(sender_id, receiver_id):
        raise HTTPException(status_code=400, detail="Already friends")
        
    # Check if pending request exists (both directions)
    existing_req = await friend_repo.get_pending_request(sender_id, receiver_id)
    if existing_req:
        raise HTTPException(status_code=400, detail="Friend request already sent")
        
    existing_req_reverse = await friend_repo.get_pending_request(receiver_id, sender_id)
    if existing_req_reverse:
        raise HTTPException(status_code=400, detail="User has already sent you a friend request")
        
    # Create request
    fr = await friend_repo.create_friend_request(sender_id, receiver_id)
    
    # Notification & Activity
    await notification_service.create_notification(
        user_id=receiver_id,
        title="New Friend Request",
        message=f"{current_user.display_name} sent you a friend request",
        type="FRIEND_REQUEST",
        sender_avatar=current_user.profile_picture
    )
    await act_repo.create_activity_log(
        user_id=sender_id,
        action="SEND_REQUEST",
        metadata={"receiver_id": receiver_id, "request_id": str(fr.id)}
    )
    return {"status": "success", "message": "Friend request sent"}

async def get_pending_requests(current_user: User) -> List[PendingRequestResponse]:
    reqs = await friend_repo.get_incoming_pending_requests(str(current_user.id))
    response = []
    for r in reqs:
        sender = await friend_repo.find_user_by_id(r.sender_id)
        if sender:
            response.append(PendingRequestResponse(
                request_id=str(r.id),
                username=sender.username,
                display_name=sender.display_name,
                profile_image=sender.profile_picture,
                created_at=r.created_at.isoformat()
            ))
    return response

async def get_sent_requests(current_user: User) -> List[PendingRequestResponse]:
    reqs = await friend_repo.get_sent_requests(str(current_user.id))
    response = []
    for r in reqs:
        receiver = await friend_repo.find_user_by_id(r.receiver_id)
        if receiver:
            response.append(PendingRequestResponse(
                request_id=str(r.id),
                username=receiver.username,
                display_name=receiver.display_name,
                profile_image=receiver.profile_picture,
                created_at=r.created_at.isoformat()
            ))
    return response

async def accept_request(action: FriendRequestAction, current_user: User):
    req = await friend_repo.get_request_by_id(action.request_id)
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    
    if req.receiver_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Cannot accept other's request")
        
    if req.status != "PENDING":
        raise HTTPException(status_code=400, detail=f"Request is already {req.status.lower()}")
        
    req.status = "ACCEPTED"
    await friend_repo.update_friend_request(req)
    
    await friend_repo.create_friendship(req.sender_id, req.receiver_id)
    
    await friend_repo.increment_friend_count(req.sender_id)
    await friend_repo.increment_friend_count(req.receiver_id)
    
    await notification_service.create_notification(
        user_id=req.sender_id,
        title="Friend Request Accepted",
        message=f"{current_user.display_name} accepted your friend request",
        type="FRIEND_ACCEPTED",
        sender_avatar=current_user.profile_picture
    )
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="ACCEPT_REQUEST",
        metadata={"sender_id": req.sender_id, "request_id": str(req.id)}
    )
    return {"status": "success", "message": "Friend request accepted"}

async def reject_request(action: FriendRequestAction, current_user: User):
    req = await friend_repo.get_request_by_id(action.request_id)
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    
    if req.receiver_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Cannot reject other's request")
        
    if req.status != "PENDING":
        raise HTTPException(status_code=400, detail=f"Request is already {req.status.lower()}")
        
    req.status = "REJECTED"
    await friend_repo.update_friend_request(req)
    
    await notification_service.create_notification(
        user_id=req.sender_id,
        title="Friend Request Rejected",
        message=f"{current_user.display_name} rejected your friend request",
        type="FRIEND_REJECTED",
        sender_avatar=current_user.profile_picture
    )
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="REJECT_REQUEST",
        metadata={"sender_id": req.sender_id, "request_id": str(req.id)}
    )
    return {"status": "success", "message": "Friend request rejected"}

async def cancel_request(action: FriendRequestAction, current_user: User):
    req = await friend_repo.get_request_by_id(action.request_id)
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    
    if req.sender_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Cannot cancel other's request")
        
    if req.status != "PENDING":
        raise HTTPException(status_code=400, detail="Only pending requests can be cancelled")
        
    req.status = "CANCELLED"
    await friend_repo.update_friend_request(req)
    return {"status": "success", "message": "Friend request cancelled"}

async def remove_friend(friend_id: str, current_user: User):
    success = await friend_repo.delete_friendship(str(current_user.id), friend_id)
    if not success:
        raise HTTPException(status_code=400, detail="Friendship does not exist")
        
    await friend_repo.decrement_friend_count(str(current_user.id))
    await friend_repo.decrement_friend_count(friend_id)
    
    await act_repo.create_activity_log(
        user_id=str(current_user.id),
        action="REMOVE_FRIEND",
        metadata={"friend_id": friend_id}
    )
    
    # Notify friend
    await notification_service.create_notification(
        user_id=friend_id,
        title="Friend Removed",
        message=f"{current_user.display_name} has removed you from their friends list",
        type="SYSTEM",
        sender_avatar=current_user.profile_picture
    )
    
    return {"status": "success", "message": "Friend removed"}

async def list_friends(current_user: User) -> List[FriendResponse]:
    friendships = await friend_repo.list_friends(str(current_user.id))
    response = []
    current_user_id = str(current_user.id)
    
    for f in friendships:
        friend_id = f.user2 if f.user1 == current_user_id else f.user1
        friend_user = await friend_repo.find_user_by_id(friend_id)
        if friend_user:
            response.append(FriendResponse(
                id=str(friend_user.id),
                username=friend_user.username,
                display_name=friend_user.display_name,
                status=friend_user.status,
                friends_since=f.created_at.isoformat()
            ))
    return response
