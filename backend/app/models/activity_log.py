from datetime import datetime, timezone
from beanie import Document # pyright: ignore[reportMissingImports]
import pymongo # pyright: ignore[reportMissingImports]
from pymongo import IndexModel, ASCENDING # pyright: ignore[reportMissingImports]
from pydantic import Field
from typing import Annotated

def utc_now():
    return datetime.now(timezone.utc)

class ActivityLog(Document):
    user_id: str
    action: str  # CREATE_ASK, REPLY, LOGIN, etc.
    metadata: Annotated[dict, Field(default_factory=dict)]
    created_at: Annotated[datetime, Field(default_factory=utc_now)]

    class Settings:
        name = "activity_logs"
        indexes = [
            IndexModel([("user_id", ASCENDING)])
        ]