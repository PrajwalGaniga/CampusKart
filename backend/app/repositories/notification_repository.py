from app.models.notification import Notification

async def create_notification(user_id: str, title: str, message: str, type: str) -> Notification:
    n = Notification(
        user_id=user_id,
        title=title,
        message=message,
        type=type
    )
    await n.insert()
    return n
