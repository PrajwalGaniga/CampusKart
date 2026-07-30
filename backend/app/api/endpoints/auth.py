from fastapi import APIRouter, Header, Depends
from app.schemas.user import UserCreate, UserLogin, Token, UserResponse
from app.api.deps import get_current_user
from app.models.user import User
from app.services import auth as auth_service

router = APIRouter()

@router.post("/register", response_model=UserResponse, status_code=201)
async def register(user_in: UserCreate):
    user = await auth_service.register_user(user_in)
    return UserResponse(
        id=str(user.id),
        username=user.username,
        display_name=user.display_name,
        email=user.email,
        role=user.role,
        status=user.status
    )

@router.post("/login", response_model=Token)
async def login(user_in: UserLogin, user_agent: str = Header(default="unknown")):
    return await auth_service.login_user(user_in, device=user_agent)

@router.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    return await auth_service.logout_user(str(current_user.id))
