from fastapi import HTTPException, status
from app.models.user import User
from app.schemas.user import UserUpdate, PasswordChange, UserResponse
from app.core.security import get_password_hash, verify_password

async def get_profile(user_id: str) -> UserResponse:
    user = await User.get(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return await _map_to_response(user)

async def update_profile(user_id: str, data: UserUpdate) -> UserResponse:
    user = await User.get(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    update_data = data.model_dump(exclude_unset=True)
    if not update_data:
        return await _map_to_response(user)
        
    for key, value in update_data.items():
        setattr(user, key, value)
        
    await user.save()
    return await _map_to_response(user)

async def change_password(user_id: str, data: PasswordChange) -> dict:
    user = await User.get(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    if not verify_password(data.old_password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Incorrect old password")
        
    user.password_hash = get_password_hash(data.new_password)
    await user.save()
    
    return {"success": True, "message": "Password changed successfully"}

async def _map_to_response(user: User) -> UserResponse:
    from app.models.ask import Ask
    from app.models.reply import Reply
    
    asks_count = await Ask.find(Ask.requester_id == str(user.id)).count()
    helps_count = await Reply.find(Reply.responder_id == str(user.id)).count()

    return UserResponse(
        id=str(user.id),
        username=user.username,
        display_name=user.display_name,
        email=user.email,
        role=user.role,
        status=user.status,
        bio=user.bio,
        profile_picture=user.profile_picture,
        friends_count=user.friends_count,
        asks_count=asks_count,
        helps_count=helps_count
    )
