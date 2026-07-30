from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field

def utc_now():
    return datetime.now(timezone.utc)

class ActivityLog(Document):
    user_id: str
    action: str  # CREATE_ASK, REPLY, LOGIN, etc.
    metadata: dict = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=utc_now)

    class Settings:
        name = "activity_logs"
        indexes = [
            IndexModel([("user_id", ASCENDING)])
        ]