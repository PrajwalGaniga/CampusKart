from fastapi import APIRouter, Depends
from typing import List
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.activity_log import ActivityLogResponse
from app.services import activity_service

router = APIRouter()

@router.get("/", response_model=List[ActivityLogResponse])
async def get_activity_logs(current_user: User = Depends(get_current_user)):
    return await activity_service.list_activity(str(current_user.id))
