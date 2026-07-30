from app.models.activity_log import ActivityLog
from app.schemas.activity_log import ActivityLogResponse
from typing import List

async def list_activity(user_id: str) -> List[ActivityLogResponse]:
    # Sort by newest first
    logs = await ActivityLog.find(ActivityLog.user_id == user_id).sort("-created_at").to_list()
    return [_map_to_response(log) for log in logs]

def _map_to_response(log: ActivityLog) -> ActivityLogResponse:
    return ActivityLogResponse(
        id=str(log.id),
        user_id=log.user_id,
        action=log.action,
        metadata=log.metadata,
        created_at=log.created_at
    )
