from typing import List, Optional
from bson import ObjectId
from bson.errors import InvalidId
from beanie.operators import In, And
import pymongo
from app.models.ask import Ask
from app.core.config import settings
from datetime import datetime, timezone

def utc_now():
    return datetime.now(timezone.utc)

async def create(ask: Ask) -> Ask:
    await ask.insert()
    return ask

async def find_by_id(ask_id: str) -> Optional[Ask]:
    try:
        oid = ObjectId(ask_id)
        return await Ask.get(oid)
    except InvalidId:
        return None

async def find_feed(friend_ids: List[str], skip: int = 0, limit: int = 20) -> List[Ask]:
    return await Ask.find(
        In(Ask.requester_id, friend_ids),
        Ask.status == "OPEN",
        Ask.expires_at > utc_now(),
        Ask.is_active == True
    ).sort("-created_at").skip(skip).limit(limit).to_list()

async def find_my_asks(user_id: str, skip: int = 0, limit: int = 20) -> List[Ask]:
    return await Ask.find(
        Ask.requester_id == user_id,
        Ask.is_active == True
    ).sort("-created_at").skip(skip).limit(limit).to_list()

async def atomic_increment_and_lock(ask_id: str) -> int:
    """
    Atomically increments the reply count.
    Returns the new reply count.
    If the document doesn't match the criteria (OPEN, not expired, reply_count < max_replies),
    it will not update and will return 0 or None.
    """
    now = utc_now()
    
    try:
        oid = ObjectId(ask_id)
    except InvalidId:
        return -1

    # We use pymongo directly for the atomic update to ensure exact control over the return document
    result = await Ask.get_motor_collection().find_one_and_update(
        {
            "_id": oid,
            "status": "OPEN",
            "expires_at": {"$gt": now},
            "reply_count": {"$lt": settings.ASK_MAX_REPLIES},
            "is_active": True
        },
        {
            "$inc": {"reply_count": 1}
        },
        return_document=pymongo.ReturnDocument.AFTER
    )
    
    if not result:
        return -1  # Conflict or not found/not open
        
    new_count = result.get("reply_count", 0)
    
    # If we reached the limit, immediately lock the ask
    if new_count >= settings.ASK_MAX_REPLIES:
        await Ask.get_motor_collection().update_one(
            {"_id": ObjectId(ask_id)},
            {"$set": {"status": "LOCKED"}}
        )
        
    return new_count

async def resolve(ask_id: str, reply_id: str) -> bool:
    try:
        oid = ObjectId(ask_id)
    except InvalidId:
        return False
        
    result = await Ask.get_motor_collection().update_one(
        {
            "_id": oid,
            "status": {"$in": ["OPEN", "LOCKED"]},
            "is_active": True
        },
        {
            "$set": {
                "status": "RESOLVED",
                "resolved_by_reply_id": reply_id,
                "resolved_at": utc_now()
            }
        }
    )
    return result.modified_count > 0

async def soft_delete(ask_id: str) -> bool:
    try:
        oid = ObjectId(ask_id)
    except InvalidId:
        return False
        
    result = await Ask.get_motor_collection().update_one(
        {"_id": oid},
        {"$set": {"is_active": False, "status": "EXPIRED"}}
    )
    return result.modified_count > 0
