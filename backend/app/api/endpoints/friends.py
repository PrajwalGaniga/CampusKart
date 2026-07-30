from fastapi import APIRouter, Depends, Query
from typing import List
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.friend import (
    UserSearchResponse, FriendRequestCreate, FriendRequestAction,
    PendingRequestResponse, FriendResponse
)
from app.services import friend_service

router = APIRouter()

@router.get("/search", response_model=List[UserSearchResponse])
async def search_users(query: str = Query(...), current_user: User = Depends(get_current_user)):
    return await friend_service.search_users(query, current_user)

@router.post("/request")
async def send_request(req: FriendRequestCreate, current_user: User = Depends(get_current_user)):
    return await friend_service.send_friend_request(req, current_user)

@router.get("/pending", response_model=List[PendingRequestResponse])
async def pending_requests(current_user: User = Depends(get_current_user)):
    return await friend_service.get_pending_requests(current_user)

@router.get("/sent", response_model=List[PendingRequestResponse])
async def sent_requests(current_user: User = Depends(get_current_user)):
    return await friend_service.get_sent_requests(current_user)

@router.post("/accept")
async def accept_request(action: FriendRequestAction, current_user: User = Depends(get_current_user)):
    return await friend_service.accept_request(action, current_user)

@router.post("/reject")
async def reject_request(action: FriendRequestAction, current_user: User = Depends(get_current_user)):
    return await friend_service.reject_request(action, current_user)

@router.post("/cancel")
async def cancel_request(action: FriendRequestAction, current_user: User = Depends(get_current_user)):
    return await friend_service.cancel_request(action, current_user)

@router.delete("/{friend_id}")
async def remove_friend(friend_id: str, current_user: User = Depends(get_current_user)):
    return await friend_service.remove_friend(friend_id, current_user)

@router.get("/", response_model=List[FriendResponse])
async def list_friends(current_user: User = Depends(get_current_user)):
    return await friend_service.list_friends(current_user)
