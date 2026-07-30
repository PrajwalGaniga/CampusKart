from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class CreateAskRequest(BaseModel):
    text: str = Field(..., min_length=3, max_length=280, example="Need an iPhone charger near Library 2nd floor!")
    location_tag: Optional[str] = Field(default="Main Campus", max_length=50, example="Library 2nd Floor")
    visibility: Optional[str] = Field(default="friends", example="friends") # "friends" or "public"
    expiry_minutes: Optional[int] = Field(default=20, ge=1, le=120)

class CreateReplyRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=280, example="I have one! I am at table 4.")
    helper_location: Optional[str] = Field(default="Nearby", example="Library 1st Floor")
    eta_minutes: Optional[int] = Field(default=2, ge=1, le=60)

class VerifyPinRequest(BaseModel):
    pin: str = Field(..., min_length=4, max_length=4, example="4829")

class HandoffStatusRequest(BaseModel):
    handoff_status: str = Field(..., example="en_route") # "en_route" or "arrived"

class AskReplyResponse(BaseModel):
    id: str
    ask_id: str
    responder_id: str
    responder_username: str
    responder_display_name: str
    responder_phone: Optional[str] = None
    helper_location: Optional[str] = "Nearby"
    eta_minutes: Optional[int] = 2
    text: str
    created_at: str
    is_accepted: bool = False

class AskResponse(BaseModel):
    id: str
    requester_id: str
    requester_username: str
    requester_display_name: str
    requester_phone: Optional[str] = None
    text: str
    location_tag: str
    visibility: str  # "friends" or "public"
    status: str      # "open", "locked", "claimed", "completed", "expired", "resolved"
    handoff_status: Optional[str] = "accepted"  # "accepted", "en_route", "arrived", "completed"
    reply_count: int
    created_at: str
    expires_at: str
    accepted_reply_id: Optional[str] = None
    accepted_responder_id: Optional[str] = None
    accepted_responder_name: Optional[str] = None
    accepted_responder_phone: Optional[str] = None
    accepted_responder_location: Optional[str] = None
    accepted_responder_eta: Optional[int] = None
    handover_pin: Optional[str] = None
    replies: Optional[List[AskReplyResponse]] = []
    is_requester: bool = False
    has_replied: bool = False
