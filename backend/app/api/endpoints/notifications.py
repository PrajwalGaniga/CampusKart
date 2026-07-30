from fastapi import APIRouter, Depends
from typing import List
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.notification import NotificationResponse
from app.services import notification_service

router = APIRouter()

@router.get("/", response_model=List[NotificationResponse])
async def get_notifications(current_user: User = Depends(get_current_user)):
    return await notification_service.list_notifications(str(current_user.id))

@router.patch("/read-all")
async def mark_all_read(current_user: User = Depends(get_current_user)):
    return await notification_service.mark_all_as_read(str(current_user.id))

@router.patch("/{notification_id}/read", response_model=NotificationResponse)
async def mark_read(notification_id: str, current_user: User = Depends(get_current_user)):
    return await notification_service.mark_as_read(notification_id, str(current_user.id))
