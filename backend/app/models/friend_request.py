from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field

def utc_now():
    return datetime.now(timezone.utc)

class FriendRequest(Document):
    sender_id: str
    receiver_id: str
    status: str = "PENDING"  # PENDING, ACCEPTED, REJECTED, CANCELLED
    created_at: datetime = Field(default_factory=utc_now)

    class Settings:
        name = "friend_requests"
        indexes = [
            IndexModel([("sender_id", ASCENDING)]),
            IndexModel([("receiver_id", ASCENDING)])
        ]