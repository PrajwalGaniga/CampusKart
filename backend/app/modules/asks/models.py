from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class CreateAskRequest(BaseModel):
    text: str = Field(..., min_length=3, max_length=280, example="Need an iPhone charger near Library 2nd floor!")
    location_tag: Optional[str] = Field(default="Main Campus", max_length=50, example="Library 2nd Floor")
    expiry_minutes: Optional[int] = Field(default=20, ge=1, le=120)

class CreateReplyRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=280, example="I have one! I am at table 4.")

class AskReplyResponse(BaseModel):
    id: str
    ask_id: str
    responder_id: str
    responder_username: str
    responder_display_name: str
    text: str
    created_at: str

class AskResponse(BaseModel):
    id: str
    requester_id: str
    requester_username: str
    requester_display_name: str
    text: str
    location_tag: str
    status: str  # "open", "locked", "expired", "resolved"
    reply_count: int
    created_at: str
    expires_at: str
    replies: Optional[List[AskReplyResponse]] = []
    is_requester: bool = False
    has_replied: bool = False
