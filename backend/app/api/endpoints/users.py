from fastapi import APIRouter, Depends
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate, PasswordChange
from app.services import user_service

router = APIRouter()

@router.get("/me", response_model=UserResponse)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    return await user_service.get_profile(str(current_user.id))

@router.put("/me", response_model=UserResponse)
async def update_my_profile(data: UserUpdate, current_user: User = Depends(get_current_user)):
    return await user_service.update_profile(str(current_user.id), data)

@router.put("/change-password")
async def change_password(data: PasswordChange, current_user: User = Depends(get_current_user)):
    return await user_service.change_password(str(current_user.id), data)
