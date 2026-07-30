from pydantic import BaseModel
from typing import Optional, List

class FriendSearchUser(BaseModel):
    id: str
    username: str
    display_name: str
    status: str  # "none", "friends", "pending_sent", "pending_received"

class FriendRequest(BaseModel):
    friend_id: str

class FriendResponse(BaseModel):
    id: str
    user_id: str
    friend_id: str
    status: str  # "pending", "accepted"
    friend_username: Optional[str] = None
    friend_display_name: Optional[str] = None
    created_at: str

class AcceptRejectRequest(BaseModel):
    request_id: str
