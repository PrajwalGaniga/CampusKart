from fastapi import APIRouter, HTTPException, Depends, Query
from typing import List
from datetime import datetime
from bson import ObjectId
import io
import base64
import qrcode
from app.database import get_db
from app.modules.auth.utils import get_current_user
from app.modules.friends.models import FriendSearchUser, FriendRequest, FriendResponse, AcceptRejectRequest

router = APIRouter(prefix="/api/friends", tags=["friends"])

@router.get("", response_model=List[dict])
async def get_friends(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    # Find edges where user_id is either user_id or friend_id, status accepted
    cursor = db.friend_edges.find({
        "$or": [
            {"user_id": user_id, "status": "accepted"},
            {"friend_id": user_id, "status": "accepted"}
        ]
    })
    
    friends_list = []
    async for edge in cursor:
        other_id = edge["friend_id"] if edge["user_id"] == user_id else edge["user_id"]
        other_user = await db.users.find_one({"_id": ObjectId(other_id)})
        if other_user:
            friends_list.append({
                "edge_id": str(edge["_id"]),
                "id": str(other_user["_id"]),
                "username": other_user.get("username"),
                "display_name": other_user.get("display_name"),
                "created_at": edge.get("created_at")
            })
    return friends_list

@router.get("/requests")
async def get_friend_requests(current_user: dict = Depends(get_current_user)):
    db = get_db()
    user_id = str(current_user["_id"])
    
    received_cursor = db.friend_edges.find({"friend_id": user_id, "status": "pending"})
    received = []
    async for edge in received_cursor:
        sender = await db.users.find_one({"_id": ObjectId(edge["user_id"])})
        if sender:
            received.append({
                "request_id": str(edge["_id"]),
                "sender_id": str(sender["_id"]),
                "sender_username": sender.get("username"),
                "sender_display_name": sender.get("display_name"),
                "created_at": edge.get("created_at")
            })

    sent_cursor = db.friend_edges.find({"user_id": user_id, "status": "pending"})
    sent = []
    async for edge in sent_cursor:
        recipient = await db.users.find_one({"_id": ObjectId(edge["friend_id"])})
        if recipient:
            sent.append({
                "request_id": str(edge["_id"]),
                "recipient_id": str(recipient["_id"]),
                "recipient_username": recipient.get("username"),
                "recipient_display_name": recipient.get("display_name"),
                "created_at": edge.get("created_at")
            })

    return {"received": received, "sent": sent}

@router.get("/search", response_model=List[FriendSearchUser])
async def search_users(query: str = Query(..., min_length=1), current_user: dict = Depends(get_current_user)):
    db = get_db()
    my_id = str(current_user["_id"])
    
    users_cursor = db.users.find({
        "username": {"$regex": query, "$options": "i"},
        "_id": {"$ne": current_user["_id"]}
    }).limit(20)
    
    results = []
    async for user in users_cursor:
        other_id = str(user["_id"])
        
        # Check existing edge
        edge = await db.friend_edges.find_one({
            "$or": [
                {"user_id": my_id, "friend_id": other_id},
                {"user_id": other_id, "friend_id": my_id}
            ]
        })
        
        status_str = "none"
        if edge:
            if edge["status"] == "accepted":
                status_str = "friends"
            elif edge["user_id"] == my_id:
                status_str = "pending_sent"
            else:
                status_str = "pending_received"
                
        results.append(FriendSearchUser(
            id=other_id,
            username=user.get("username"),
            display_name=user.get("display_name"),
            status=status_str
        ))
        
    return results

@router.post("/request")
async def send_friend_request(req: FriendRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    my_id = str(current_user["_id"])
    target_id = req.friend_id
    
    if my_id == target_id:
        raise HTTPException(status_code=400, detail="Cannot add yourself as friend")
        
    target_user = await db.users.find_one({"_id": ObjectId(target_id)})
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    existing = await db.friend_edges.find_one({
        "$or": [
            {"user_id": my_id, "friend_id": target_id},
            {"user_id": target_id, "friend_id": my_id}
        ]
    })
    
    now = datetime.utcnow().isoformat()
    if existing:
        if existing["status"] == "accepted":
            return {"message": "Already friends"}
        elif existing["user_id"] == target_id and existing["status"] == "pending":
            # Auto accept reverse request!
            await db.friend_edges.update_one(
                {"_id": existing["_id"]},
                {"$set": {"status": "accepted"}}
            )
            return {"message": "Mutual friend request accepted automatically!"}
        else:
            return {"message": "Friend request already pending"}
            
    edge_doc = {
        "user_id": my_id,
        "friend_id": target_id,
        "status": "pending",
        "created_at": now
    }
    await db.friend_edges.insert_one(edge_doc)
    return {"message": "Friend request sent"}

@router.post("/accept")
async def accept_friend_request(req: AcceptRejectRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    my_id = str(current_user["_id"])
    
    edge = await db.friend_edges.find_one({"_id": ObjectId(req.request_id), "friend_id": my_id})
    if not edge:
        raise HTTPException(status_code=404, detail="Friend request not found")
        
    await db.friend_edges.update_one(
        {"_id": edge["_id"]},
        {"$set": {"status": "accepted"}}
    )
    return {"message": "Friend request accepted"}

@router.post("/reject")
async def reject_friend_request(req: AcceptRejectRequest, current_user: dict = Depends(get_current_user)):
    db = get_db()
    my_id = str(current_user["_id"])
    
    res = await db.friend_edges.delete_one({"_id": ObjectId(req.request_id), "$or": [{"friend_id": my_id}, {"user_id": my_id}]})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Friend request not found")
    return {"message": "Friend request rejected/cancelled"}

@router.get("/qr")
async def generate_qr(current_user: dict = Depends(get_current_user)):
    username = current_user["username"]
    qr_payload = f"campusask:user:{username}"
    
    img = qrcode.make(qr_payload)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    img_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
    
    return {
        "qr_payload": qr_payload,
        "username": username,
        "qr_image_url": f"data:image/png;base64,{img_b64}"
    }

@router.post("/qr-add")
async def add_by_qr(payload: dict, current_user: dict = Depends(get_current_user)):
    raw_code = payload.get("qr_code", "").strip()
    if not raw_code.startswith("campusask:user:"):
        raise HTTPException(status_code=400, detail="Invalid QR Code payload")
        
    target_username = raw_code.replace("campusask:user:", "").strip().lower()
    if target_username == current_user["username"].lower():
        raise HTTPException(status_code=400, detail="Cannot add yourself as a friend")
        
    db = get_db()
    target_user = await db.users.find_one({"username": target_username})
    if not target_user:
        raise HTTPException(status_code=404, detail="Target user not found")
        
    target_id = str(target_user["_id"])
    my_id = str(current_user["_id"])
    
    existing = await db.friend_edges.find_one({
        "$or": [
            {"user_id": my_id, "friend_id": target_id},
            {"user_id": target_id, "friend_id": my_id}
        ]
    })
    
    now = datetime.utcnow().isoformat()
    if existing:
        if existing["status"] != "accepted":
            await db.friend_edges.update_one(
                {"_id": existing["_id"]},
                {"$set": {"status": "accepted"}}
            )
            return {"message": f"Successfully friended @{target_username} via QR Code!"}
        return {"message": f"You are already friends with @{target_username}"}
    
    # Create auto-accepted friendship via QR scan
    edge_doc = {
        "user_id": my_id,
        "friend_id": target_id,
        "status": "accepted",
        "created_at": now
    }
    await db.friend_edges.insert_one(edge_doc)
    return {"message": f"Successfully friended @{target_username} via QR Code!"}
