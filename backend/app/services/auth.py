from fastapi import HTTPException, status
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, Token
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token
from app.models.session import Session
from datetime import datetime, timezone, timedelta
from app.core.config import settings

async def register_user(user_in: UserCreate) -> User:
    user = await User.find_one({"$or": [{"username": user_in.username}, {"email": user_in.email}]})
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this username or email already exists"
        )
    
    pic = user_in.profile_picture
    if pic and not pic.startswith("/static/avatars/"):
        pic = f"/static/avatars/{pic}"
    
    new_user = User(
        username=user_in.username,
        display_name=user_in.display_name,
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        department=user_in.department,
        year=user_in.year,
        section=user_in.section,
        profile_picture=pic,
        role="STUDENT"
    )
    await new_user.insert()
    return new_user

async def login_user(user_in: UserLogin, device: str) -> Token:
    user = await User.find_one(User.username == user_in.username)
    if not user or not verify_password(user_in.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
        
    access_token = create_access_token(subject=str(user.id))
    refresh_token = create_refresh_token(subject=str(user.id))
    
    expires_at = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    
    session = Session(
        user_id=str(user.id),
        refresh_token=refresh_token,
        device=device,
        expires_at=expires_at
    )
    await session.insert()
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token
    )

async def logout_user(user_id: str) -> dict:
    """MVP: Delete all sessions for the user to log them out of all devices."""
    await Session.find(Session.user_id == user_id).delete()
    return {"success": True, "message": "Successfully logged out"}
