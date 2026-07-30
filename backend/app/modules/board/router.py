from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import List
from datetime import datetime
from app.database import get_db
from app.websocket import manager

router = APIRouter(prefix="", tags=["board"])

@router.get("/api/board")
async def get_public_board():
    db = get_db()
    now_iso = datetime.utcnow().isoformat()
    
    # Get active asks that are not expired
    cursor = db.asks.find({
        "status": {"$in": ["open", "locked", "resolved"]},
        "expires_at": {"$gt": now_iso}
    }).sort("created_at", -1).limit(30)
    
    board_asks = []
    async for ask in cursor:
        board_asks.append({
            "id": str(ask["_id"]),
            "text": ask.get("text", ""),
            "location_tag": ask.get("location_tag", "Main Campus"),
            "status": ask.get("status", "open"),
            "reply_count": ask.get("reply_count", 0),
            "created_at": ask.get("created_at"),
            "expires_at": ask.get("expires_at")
        })
        
    return board_asks

@router.websocket("/ws/board")
async def websocket_board_endpoint(websocket: WebSocket):
    await manager.connect_board(websocket)
    try:
        while True:
            # Keep connection open and receive optional ping messages
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect_board(websocket)
    except Exception:
        manager.disconnect_board(websocket)
