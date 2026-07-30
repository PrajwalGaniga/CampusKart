from typing import List, Optional
from bson import ObjectId
from app.models.reply import Reply

async def create_reply(ask_id: str, responder_id: str, message: str) -> Reply:
    reply = Reply(ask_id=ask_id, responder_id=responder_id, message=message)
    await reply.insert()
    return reply

async def find_reply_by_user_and_ask(ask_id: str, responder_id: str) -> Optional[Reply]:
    return await Reply.find_one(
        Reply.ask_id == ask_id,
        Reply.responder_id == responder_id
    )

async def list_replies_for_ask(ask_id: str) -> List[Reply]:
    return await Reply.find(
        Reply.ask_id == ask_id,
        Reply.status == "ACTIVE"
    ).sort("-created_at").to_list()
