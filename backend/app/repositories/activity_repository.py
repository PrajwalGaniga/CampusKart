from app.models.activity_log import ActivityLog

async def create_activity_log(user_id: str, action: str, metadata: dict = None) -> ActivityLog:
    if metadata is None:
        metadata = {}
    log = ActivityLog(
        user_id=user_id,
        action=action,
        metadata=metadata
    )
    await log.insert()
    return log
