from fastapi import APIRouter, Depends, Query
from typing import List
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.ask import AskCreate, AskResponse, ReplyCreate, ReplyResponse, AskResolve
from app.services import ask_service

router = APIRouter()

@router.post("/", response_model=AskResponse)
async def create_ask(req: AskCreate, current_user: User = Depends(get_current_user)):
    return await ask_service.create_ask(req, current_user)

@router.get("/feed", response_model=List[AskResponse])
async def get_feed(skip: int = 0, limit: int = 20, current_user: User = Depends(get_current_user)):
    return await ask_service.list_feed(current_user, skip, limit)

@router.get("/my", response_model=List[AskResponse])
async def get_my_asks(skip: int = 0, limit: int = 20, current_user: User = Depends(get_current_user)):
    return await ask_service.list_my_asks(current_user, skip, limit)

@router.get("/{ask_id}", response_model=AskResponse)
async def get_ask(ask_id: str, current_user: User = Depends(get_current_user)):
    return await ask_service.get_ask(ask_id, current_user)

@router.post("/{ask_id}/reply")
async def reply_to_ask(ask_id: str, req: ReplyCreate, current_user: User = Depends(get_current_user)):
    return await ask_service.reply_to_ask(ask_id, req, current_user)

@router.get("/{ask_id}/replies", response_model=List[ReplyResponse])
async def get_replies(ask_id: str, current_user: User = Depends(get_current_user)):
    return await ask_service.list_replies(ask_id, current_user)

@router.post("/{ask_id}/resolve")
async def resolve_ask(ask_id: str, req: AskResolve, current_user: User = Depends(get_current_user)):
    return await ask_service.resolve_ask(ask_id, req.reply_id, current_user)

@router.delete("/{ask_id}")
async def delete_ask(ask_id: str, current_user: User = Depends(get_current_user)):
    return await ask_service.delete_ask(ask_id, current_user)
