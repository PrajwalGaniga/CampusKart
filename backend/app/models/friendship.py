from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field

def utc_now():
    return datetime.now(timezone.utc)

class Friendship(Document):
    user1: str
    user2: str
    created_at: datetime = Field(default_factory=utc_now)

    class Settings:
        name = "friendships"
        indexes = [
            IndexModel([("user1", ASCENDING)]),
            IndexModel([("user2", ASCENDING)])
        ]