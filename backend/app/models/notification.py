from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field

def utc_now():
    return datetime.now(timezone.utc)

class Notification(Document):
    user_id: str
    title: str
    message: str
    type: str  # ASK, REPLY, FRIEND_REQUEST, FRIEND_ACCEPTED, SYSTEM
    is_read: bool = False
    created_at: datetime = Field(default_factory=utc_now)

    class Settings:
        name = "notifications"
        indexes = [
            IndexModel([("user_id", ASCENDING)])
        ]