from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field
import pymongo
from pymongo import IndexModel, ASCENDING

def utc_now():
    return datetime.now(timezone.utc)

class Reply(Document):
    ask_id: str
    responder_id: str
    message: str
    status: str = "ACTIVE"
    created_at: datetime = Field(default_factory=utc_now)

    class Settings:
        name = "replies"
        indexes = [
            IndexModel([("ask_id", ASCENDING), ("responder_id", ASCENDING)], unique=True)
        ]