from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class SignupRequest(BaseModel):
    phone: str = Field(..., example="+1234567890")
    email: EmailStr = Field(..., example="user@campus.edu")
    username: str = Field(..., min_length=3, max_length=30, example="johndoe")
    display_name: str = Field(..., min_length=1, max_length=50, example="John Doe")
    password: str = Field(..., min_length=6, example="secret123")

class LoginRequest(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: str
    phone: str
    email: str
    username: str
    display_name: str
    created_at: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
