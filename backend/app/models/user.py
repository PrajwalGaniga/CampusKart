from datetime import datetime, timezone
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING
from pydantic import Field

def utc_now():
    return datetime.now(timezone.utc)

class User(Document):
    username: str
    display_name: str
    email: str
    password_hash: str
    
    profile_picture: str = ""
    bio: str = ""
    
    
    department: str
    year: int
    section: str
    
    role: str = "STUDENT"  # STUDENT, ADMIN
    status: str = "ONLINE"  # ONLINE, OFFLINE
    
    friends_count: int = 0
    
    created_at: datetime = Field(default_factory=utc_now)
    updated_at: datetime = Field(default_factory=utc_now)
    last_seen: datetime = Field(default_factory=utc_now)
    
    is_active: bool = True

    class Settings:
        name = "users"
        indexes = [
            IndexModel([("username", ASCENDING)], unique=True),
            IndexModel([("email", ASCENDING)], unique=True),
            IndexModel([("status", ASCENDING)])
        ]