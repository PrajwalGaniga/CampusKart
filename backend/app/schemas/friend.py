from pydantic import BaseModel
from typing import Optional

class UserSearchResponse(BaseModel):
    id: str
    username: str
    display_name: str
    profile_image: str
    status: str
    friendship_status: str = "NONE"

class FriendRequestCreate(BaseModel):
    username: str

class FriendRequestAction(BaseModel):
    request_id: str

class PendingRequestResponse(BaseModel):
    request_id: str
    username: str
    display_name: str
    profile_image: str
    created_at: str

class FriendResponse(BaseModel):
    id: str
    username: str
    display_name: str
    profile_image: str
    status: str
    friends_since: str
