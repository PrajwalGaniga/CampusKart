from datetime import datetime, timezone
from beanie import Document
from pydantic import Field
from typing import Optional
import pymongo
from pymongo import IndexModel, ASCENDING

def utc_now():
    return datetime.now(timezone.utc)

class Ask(Document):
    requester_id: str
    title: str
    description: str
    category: str  # ACADEMIC, ITEMS, FOOD, TRANSPORT, LOCATION, EMERGENCY, EVENT, OTHER
    location: str
    visibility: str = "FRIENDS"
    
    status: str = "OPEN"  # OPEN, LOCKED, RESOLVED, EXPIRED
    
    max_replies: int = 5
    reply_count: int = 0
    resolved_by_reply_id: Optional[str] = None
    
    is_active: bool = True
    
    created_at: datetime = Field(default_factory=utc_now)
    expires_at: datetime
    resolved_at: Optional[datetime] = None

    class Settings:
        name = "asks"
        indexes = [
            IndexModel([("requester_id", ASCENDING)]),
            IndexModel([("status", ASCENDING)]),
            IndexModel([("category", ASCENDING)]),
            IndexModel([("location", ASCENDING)]),
            IndexModel([("expires_at", ASCENDING)], expireAfterSeconds=0)
        ]