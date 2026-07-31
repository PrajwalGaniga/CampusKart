from fastapi import HTTPException, status
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse
from typing import List
from app.core.event_publisher import event_publisher

async def create_notification(user_id: str, title: str, message: str, type: str, sender_avatar: str = "") -> NotificationResponse:
    notification = Notification(
        user_id=user_id,
        title=title,
        message=message,
        type=type,
        sender_avatar=sender_avatar
    )
    await notification.insert()
    
    # Push real-time notification to the user via WebSocket
    # We could theoretically include sender_avatar here, but omitting for now if the frontend doesn't need it on socket yet
    await event_publisher.send_notification(user_id, title, message, type)
    
    return _map_to_response(notification)

async def list_notifications(user_id: str) -> List[NotificationResponse]:
    # Sort by newest first
    notifications = await Notification.find(Notification.user_id == user_id).sort("-created_at").to_list()
    return [_map_to_response(n) for n in notifications]

async def mark_as_read(notification_id: str, user_id: str) -> NotificationResponse:
    notification = await Notification.get(notification_id)
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
        
    if notification.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")
        
    notification.is_read = True
    await notification.save()
    
    return _map_to_response(notification)

async def mark_all_as_read(user_id: str) -> dict:
    await Notification.find(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).update({"$set": {"is_read": True}})
    
    return {"success": True, "message": "All notifications marked as read"}

def _map_to_response(notification: Notification) -> NotificationResponse:
    return NotificationResponse(
        id=str(notification.id),
        user_id=notification.user_id,
        title=notification.title,
        message=notification.message,
        type=notification.type,
        sender_avatar=notification.sender_avatar,
        is_read=notification.is_read,
        created_at=notification.created_at
    )
