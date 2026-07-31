from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    username: str
    display_name: str
    email: EmailStr
    password: str
    department: str
    year: int
    section: str

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    refresh_token: str

class UserResponse(BaseModel):
    id: str
    username: str
    display_name: str
    email: str
    role: str
    status: str
    bio: str = ""
    friends_count: int = 0
    asks_count: int = 0
    helps_count: int = 0
    
    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    department: Optional[str] = None
    year: Optional[int] = None
    section: Optional[str] = None
    profile_picture: Optional[str] = None
    bio: Optional[str] = None

class PasswordChange(BaseModel):
    old_password: str
    new_password: str
