from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

class AskCategory(str, Enum):
    ACADEMIC = "ACADEMIC"
    ITEMS = "ITEMS"
    FOOD = "FOOD"
    TRANSPORT = "TRANSPORT"
    LOCATION = "LOCATION"
    EMERGENCY = "EMERGENCY"
    EVENT = "EVENT"
    OTHER = "OTHER"

class AskCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=100)
    description: str = Field(..., min_length=5, max_length=500)
    category: AskCategory
    location: str = Field(..., min_length=2, max_length=100)
    expires_in_minutes: int = Field(default=20, ge=5, le=1440)  # Max 24 hours

class AskResponse(BaseModel):
    id: str
    requester_id: str
    requester_name: str
    requester_image: str
    title: str
    description: str
    category: str
    location: str
    status: str
    reply_count: int
    max_replies: int
    created_at: str
    expires_at: str

class ReplyCreate(BaseModel):
    message: str = Field(..., min_length=1, max_length=500)

class ReplyResponse(BaseModel):
    id: str
    ask_id: str
    responder_id: str
    responder_name: str
    responder_image: str
    message: str
    created_at: str

class AskResolve(BaseModel):
    reply_id: str
