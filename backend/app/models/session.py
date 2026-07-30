from datetime import datetime
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING

class Session(Document):
    user_id: str
    refresh_token: str
    device: str
    expires_at: datetime

    class Settings:
        name = "sessions"
        indexes = [
            IndexModel([("user_id", ASCENDING)]),
            IndexModel([("refresh_token", ASCENDING)], unique=True)
        ]