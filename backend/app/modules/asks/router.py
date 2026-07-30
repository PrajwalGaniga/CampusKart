from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional
from datetime import datetime, timedelta
from bson import ObjectId
from pymongo import ReturnDocument
import random

from app.database import get_db
from app.websocket import manager
from app.modules.auth.utils import get_current_user
from app.modules.asks.models import CreateAskRequest, CreateReplyRequest, VerifyPinRequest, AskResponse, AskReplyResponse

router = APIRouter(prefix="/api/asks", tags=["asks"])

async def get_mutual_friend_ids(user_id: str) -> List[str]:
    db = get_db()
    cursor = db.friend_edges.find({
        "$or": [
            {"user_id": user_id, "status": "accepted"},
            {"friend_id": user_id, "status": "accepted"}
        ]
    })
    friend_ids = []
    async for edge in cursor:
        friend_ids.append(edge["friend_id"] if edge["user_id"] == user_id else edge["user_id"])
    return friend_ids

async def format_ask_response(ask_doc: dict, current_user_id: str) -> AskResponse:
    db = get_db()
    ask_id_str = str(ask_doc["_id"])
    
    # Check expiry
    now_dt = datetime.utcnow()
    expires_dt = datetime.fromisoformat(ask_doc["expires_at"]) if isinstance(ask_doc["expires_at"], str) else ask_doc["expires_at"]
    
    current_status = ask_doc.get("status", "open")
    if current_status == "open" and now_dt > expires_dt:
        current_status = "expired"
        await db.asks.update_one({"_id": ask_doc["_id"]}, {"$set": {"status": "expired"}})
        
    requester = await db.users.find_one({"_id": ObjectId(ask_doc["requester_id"])})
    requester_username = requester.get("username", "unknown") if requester else "unknown"
    requester_display_name = requester.get("display_name", "Anonymous") if requester else "Anonymous"
    requester_phone = requester.get("phone", "") if requester else ""
    
    accepted_reply_id = ask_doc.get("accepted_reply_id")
    accepted_responder_id = ask_doc.get("accepted_responder_id")
    
    accepted_responder_name = None
    accepted_responder_phone = None
    if accepted_responder_id:
        acc_user = await db.users.find_one({"_id": ObjectId(accepted_responder_id)})
        if acc_user:
            accepted_responder_name = acc_user.get("display_name", "Friend")
            accepted_responder_phone = acc_user.get("phone", "")

    # Fetch replies
    replies_cursor = db.replies.find({"ask_id": ask_id_str}).sort("created_at", 1)
    replies_list = []
    has_replied = False
    
    async for rep in replies_cursor:
        if rep["responder_id"] == current_user_id:
            has_replied = True
            
        resp_user = await db.users.find_one({"_id": ObjectId(rep["responder_id"])})
        
        # Phone details only revealed if requester or accepted responder
        resp_phone = None
        if current_user_id == ask_doc["requester_id"] or current_user_id == rep["responder_id"]:
            resp_phone = resp_user.get("phone", "") if resp_user else ""

        replies_list.append(AskReplyResponse(
            id=str(rep["_id"]),
            ask_id=ask_id_str,
            responder_id=rep["responder_id"],
            responder_username=resp_user.get("username", "unknown") if resp_user else "unknown",
            responder_display_name=resp_user.get("display_name", "Friend") if resp_user else "Friend",
            responder_phone=resp_phone,
            text=rep["text"],
            created_at=rep["created_at"],
            is_accepted=(str(rep["_id"]) == accepted_reply_id)
        ))
        
    # Reveal PIN and private contact info ONLY to requester or accepted helper
    is_requester = (ask_doc["requester_id"] == current_user_id)
    is_accepted_helper = (accepted_responder_id == current_user_id)
    
    pin_to_show = ask_doc.get("handover_pin") if (is_requester or is_accepted_helper) else None
    req_phone_to_show = requester_phone if (is_requester or is_accepted_helper) else None
    acc_phone_to_show = accepted_responder_phone if (is_requester or is_accepted_helper) else None

    return AskResponse(
        id=ask_id_str,
        requester_id=ask_doc["requester_id"],
        requester_username=requester_username,
        requester_display_name=requester_display_name,
        requester_phone=req_phone_to_show,
        text=ask_doc["text"],
        location_tag=ask_doc.get("location_tag", "Main Campus"),
        visibility=ask_doc.get("visibility", "friends"),
        status=current_status,
        reply_count=ask_doc.get("reply_count", 0),
        created_at=ask_doc["created_at"],
        expires_at=ask_doc["expires_at"],
        accepted_reply_id=accepted_reply_id,
        accepted_responder_id=accepted_responder_id,
        accepted_responder_name=accepted_responder_name,
        accepted_responder_phone=acc_phone_to_show,
        handover_pin=pin_to_show,
        replies=replies_list,
        is_requester=is_requester,
        has_replied=has_replied
    )

@router.post("", response_model=AskResponse)
async def create_ask(req: CreateAskRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    now = datetime.utcnow()
    expires = now + timedelta(minutes=req.expiry_minutes)
    
    visibility_val = "public" if req.visibility == "public" else "friends"
    
    ask_doc = {
        "requester_id": user_id,
        "text": req.text.strip(),
        "location_tag": req.location_tag.strip() if req.location_tag else "Main Campus",
        "visibility": visibility_val,
        "status": "open",
        "reply_count": 0,
        "created_at": now.isoformat(),
        "expires_at": expires.isoformat()
    }
    
    res = await db.asks.insert_one(ask_doc)
    ask_doc["_id"] = res.inserted_id
    
    formatted_ask = await format_ask_response(ask_doc, user_id)
    
    ws_payload = {
        "event": "NEW_ASK",
        "ask": formatted_ask.model_dump()
    }

    if visibility_val == "public":
        # Broadcast to ALL connected users on campus
        await manager.broadcast_all_users(ws_payload)
    else:
        # Send WS to mutual friends
        friend_ids = await get_mutual_friend_ids(user_id)
        await manager.send_to_users(friend_ids, ws_payload)
    
    # Broadcast anonymized event to public board
    board_payload = {
        "event": "BOARD_NEW_ASK",
        "ask": {
            "id": formatted_ask.id,
            "text": formatted_ask.text,
            "location_tag": formatted_ask.location_tag,
            "visibility": formatted_ask.visibility,
            "status": "open",
            "reply_count": 0,
            "created_at": formatted_ask.created_at,
            "expires_at": formatted_ask.expires_at
        }
    }
    await manager.broadcast_board(board_payload)
    
    return formatted_ask

@router.get("/feed", response_model=List[AskResponse])
async def get_feed(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    friend_ids = await get_mutual_friend_ids(user_id)
    allowed_requesters = friend_ids + [user_id]
    
    # Find asks where requester is user/friend OR visibility is public
    cursor = db.asks.find({
        "$or": [
            {"requester_id": {"$in": allowed_requesters}},
            {"visibility": "public"}
        ]
    }).sort("created_at", -1).limit(50)
    
    asks_feed = []
    async for ask in cursor:
        formatted = await format_ask_response(ask, user_id)
        asks_feed.append(formatted)
        
    return asks_feed

@router.post("/{ask_id}/reply", response_model=AskReplyResponse)
async def reply_to_ask(ask_id: str, req: CreateReplyRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    try:
        ask_id_obj = ObjectId(ask_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ask ID format")
        
    ask = await db.asks.find_one({"_id": ask_id_obj})
    if not ask:
        raise HTTPException(status_code=404, detail="Ask not found")
        
    # Check expiry
    now_dt = datetime.utcnow()
    expires_dt = datetime.fromisoformat(ask["expires_at"])
    if now_dt > expires_dt or ask.get("status") == "expired":
        if ask.get("status") == "open":
            await db.asks.update_one({"_id": ask_id_obj}, {"$set": {"status": "expired"}})
        raise HTTPException(status_code=400, detail="This ask has expired")
        
    if ask.get("status") != "open":
        raise HTTPException(status_code=409, detail="This ask is already closed or claimed")
        
    # Prevent duplicate reply from same user
    existing_reply = await db.replies.find_one({"ask_id": ask_id, "responder_id": user_id})
    if existing_reply:
        raise HTTPException(status_code=400, detail="You have already replied to this ask")

    # CRITICAL 5-REPLY ATOMIC LOCK OPERATION
    result = await db.asks.find_one_and_update(
        {"_id": ask_id_obj, "status": "open", "reply_count": {"$lt": 5}},
        {"$inc": {"reply_count": 1}},
        return_document=ReturnDocument.AFTER
    )
    if result is None:
        raise HTTPException(status_code=409, detail="This ask is already closed or claimed")
        
    # If 5th reply recorded, lock status atomically
    if result["reply_count"] >= 5:
        await db.asks.update_one(
            {"_id": ask_id_obj},
            {"$set": {"status": "locked"}}
        )
        result["status"] = "locked"

    # Insert reply document
    now_str = datetime.utcnow().isoformat()
    reply_doc = {
        "ask_id": ask_id,
        "responder_id": user_id,
        "text": req.text.strip(),
        "created_at": now_str
    }
    
    res = await db.replies.insert_one(reply_doc)
    reply_doc["_id"] = res.inserted_id
    
    reply_response = AskReplyResponse(
        id=str(reply_doc["_id"]),
        ask_id=ask_id,
        responder_id=user_id,
        responder_username=current_user["username"],
        responder_display_name=current_user["display_name"],
        responder_phone=current_user.get("phone", ""),
        text=reply_doc["text"],
        created_at=now_str
    )
    
    # Broadcast updates via WebSocket
    if ask.get("visibility") == "public":
        updated_ask = await format_ask_response(result, user_id)
        await manager.broadcast_all_users({"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
    else:
        friend_ids = await get_mutual_friend_ids(ask["requester_id"])
        all_notified = list(set(friend_ids + [ask["requester_id"]]))
        updated_ask = await format_ask_response(result, user_id)
        await manager.send_to_users(all_notified, {"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
    
    # Broadcast public board update
    await manager.broadcast_board({
        "event": "BOARD_ASK_UPDATED",
        "ask": {
            "id": ask_id,
            "text": ask["text"],
            "location_tag": ask.get("location_tag", "Main Campus"),
            "status": result.get("status", "open"),
            "reply_count": result["reply_count"],
            "created_at": ask["created_at"],
            "expires_at": ask["expires_at"]
        }
    })
    
    return reply_response

@router.post("/{ask_id}/accept/{reply_id}")
async def accept_offer(ask_id: str, reply_id: str, current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    try:
        ask_id_obj = ObjectId(ask_id)
        reply_id_obj = ObjectId(reply_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ID format")
        
    ask = await db.asks.find_one({"_id": ask_id_obj, "requester_id": user_id})
    if not ask:
        raise HTTPException(status_code=404, detail="Ask not found or you are not the requester")
        
    if ask.get("status") in ["claimed", "completed", "resolved", "expired"]:
        raise HTTPException(status_code=400, detail=f"Ask is already {ask.get('status')}")
        
    reply = await db.replies.find_one({"_id": reply_id_obj, "ask_id": ask_id})
    if not reply:
        raise HTTPException(status_code=404, detail="Reply offer not found")
        
    # Generate 4-digit Handover PIN
    pin = f"{random.randint(1000, 9999)}"
    
    await db.asks.update_one(
        {"_id": ask_id_obj},
        {"$set": {
            "status": "claimed",
            "accepted_reply_id": reply_id,
            "accepted_responder_id": reply["responder_id"],
            "handover_pin": pin
        }}
    )
    ask["status"] = "claimed"
    ask["accepted_reply_id"] = reply_id
    ask["accepted_responder_id"] = reply["responder_id"]
    ask["handover_pin"] = pin
    
    # Broadcast update
    if ask.get("visibility") == "public":
        updated_ask = await format_ask_response(ask, user_id)
        await manager.broadcast_all_users({"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
    else:
        friend_ids = await get_mutual_friend_ids(user_id)
        all_notified = list(set(friend_ids + [user_id, reply["responder_id"]]))
        updated_ask = await format_ask_response(ask, user_id)
        await manager.send_to_users(all_notified, {"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
        
    await manager.broadcast_board({
        "event": "BOARD_ASK_UPDATED",
        "ask": {
            "id": ask_id,
            "text": ask["text"],
            "location_tag": ask.get("location_tag", "Main Campus"),
            "status": "claimed",
            "reply_count": ask.get("reply_count", 0),
            "created_at": ask["created_at"],
            "expires_at": ask["expires_at"]
        }
    })
    
    return {"message": "Offer accepted! Handoff PIN generated.", "handover_pin": pin}

@router.post("/{ask_id}/verify-pin")
async def verify_handover_pin(ask_id: str, req: VerifyPinRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    try:
        ask_id_obj = ObjectId(ask_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ask ID format")
        
    ask = await db.asks.find_one({"_id": ask_id_obj, "requester_id": user_id})
    if not ask:
        raise HTTPException(status_code=404, detail="Ask not found or you are not the requester")
        
    if ask.get("handover_pin") != req.pin.strip():
        raise HTTPException(status_code=400, detail="Invalid Handover PIN")
        
    await db.asks.update_one({"_id": ask_id_obj}, {"$set": {"status": "completed"}})
    ask["status"] = "completed"
    
    # Broadcast update
    if ask.get("visibility") == "public":
        updated_ask = await format_ask_response(ask, user_id)
        await manager.broadcast_all_users({"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
    else:
        friend_ids = await get_mutual_friend_ids(user_id)
        all_notified = list(set(friend_ids + [user_id]))
        updated_ask = await format_ask_response(ask, user_id)
        await manager.send_to_users(all_notified, {"event": "ASK_UPDATED", "ask": updated_ask.model_dump()})
        
    return {"message": "Item handover verified & ask completed!"}

@router.post("/{ask_id}/resolve")
async def resolve_ask(ask_id: str, current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    try:
        ask_id_obj = ObjectId(ask_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ask ID format")
        
    ask = await db.asks.find_one({"_id": ask_id_obj, "requester_id": user_id})
    if not ask:
        raise HTTPException(status_code=404, detail="Ask not found or you are not the requester")
        
    await db.asks.update_one({"_id": ask_id_obj}, {"$set": {"status": "resolved"}})
    ask["status"] = "resolved"
    
    # Notify WS
    friend_ids = await get_mutual_friend_ids(user_id)
    all_notified = list(set(friend_ids + [user_id]))
    
    updated_ask = await format_ask_response(ask, user_id)
    await manager.send_to_users(all_notified, {
        "event": "ASK_UPDATED",
        "ask": updated_ask.model_dump()
    })
    
    await manager.broadcast_board({
        "event": "BOARD_ASK_UPDATED",
        "ask": {
            "id": ask_id,
            "text": ask["text"],
            "location_tag": ask.get("location_tag", "Main Campus"),
            "status": "resolved",
            "reply_count": ask.get("reply_count", 0),
            "created_at": ask["created_at"],
            "expires_at": ask["expires_at"]
        }
    })
    
    return {"message": "Ask marked as resolved"}

@router.get("/history", response_model=List[AskResponse])
async def get_history(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    user_asks_cursor = db.asks.find({"requester_id": user_id, "cleared_by": {"$ne": user_id}})
    user_replies_cursor = db.replies.find({"responder_id": user_id})
    replied_ask_ids = [rep["ask_id"] async for rep in user_replies_cursor]
    
    replied_objs = []
    for aid in replied_ask_ids:
        try:
            replied_objs.append(ObjectId(aid))
        except Exception:
            pass
            
    replied_asks_cursor = db.asks.find({
        "_id": {"$in": replied_objs},
        "cleared_by": {"$ne": user_id}
    })
    
    all_asks_map = {}
    async for ask in user_asks_cursor:
        formatted = await format_ask_response(ask, user_id)
        all_asks_map[formatted.id] = formatted
        
    async for ask in replied_asks_cursor:
        formatted = await format_ask_response(ask, user_id)
        all_asks_map[formatted.id] = formatted
        
    result_list = list(all_asks_map.values())
    result_list.sort(key=lambda x: x.created_at, reverse=True)
    return result_list

@router.delete("/history")
async def clear_history(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    await db.asks.update_many(
        {"$or": [{"requester_id": user_id}, {"_id": {"$in": [ObjectId(aid) for aid in (await db.replies.distinct("ask_id", {"responder_id": user_id})) if ObjectId.is_valid(aid)]}}]},
        {"$addToSet": {"cleared_by": user_id}}
    )
    return {"message": "Personal history cleared"}
