from fastapi import APIRouter, HTTPException, status, Depends
from datetime import datetime
from app.database import get_db
from app.modules.auth.models import SignupRequest, LoginRequest, TokenResponse, UserResponse
from app.modules.auth.utils import hash_password, verify_password, create_access_token, get_current_user
from pymongo.errors import DuplicateKeyError

router = APIRouter(prefix="/api/auth", tags=["auth"])

def format_user_response(user_doc: dict) -> UserResponse:
    return UserResponse(
        id=str(user_doc["_id"]),
        phone=user_doc.get("phone", ""),
        email=user_doc.get("email", ""),
        username=user_doc.get("username", ""),
        display_name=user_doc.get("display_name", ""),
        created_at=user_doc.get("created_at", datetime.utcnow().isoformat())
    )

@router.post("/signup", response_model=TokenResponse)
async def signup(req: SignupRequest):
    db = get_db()
    existing_user = await db.users.find_one({"$or": [{"username": req.username.lower()}, {"email": req.email.lower()}]})
    if existing_user:
        if existing_user.get("username") == req.username.lower():
            raise HTTPException(status_code=400, detail="Username already exists")
        raise HTTPException(status_code=400, detail="Email already registered")

    now = datetime.utcnow().isoformat()
    user_doc = {
        "phone": req.phone.strip(),
        "email": req.email.lower().strip(),
        "username": req.username.lower().strip(),
        "display_name": req.display_name.strip(),
        "password_hash": hash_password(req.password),
        "created_at": now
    }

    try:
        res = await db.users.insert_one(user_doc)
        user_doc["_id"] = res.inserted_id
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Username or Email already exists")

    token = create_access_token({"sub": str(user_doc["_id"]), "username": user_doc["username"]})
    return TokenResponse(access_token=token, user=format_user_response(user_doc))

@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest):
    db = get_db()
    user = await db.users.find_one({"username": req.username.lower().strip()})
    if not user or not verify_password(req.password, user.get("password_hash", "")):
        raise HTTPException(status_code=400, detail="Invalid username or password")

    token = create_access_token({"sub": str(user["_id"]), "username": user["username"]})
    return TokenResponse(access_token=token, user=format_user_response(user))

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: dict = Depends(get_current_user)):
    return format_user_response(current_user)
