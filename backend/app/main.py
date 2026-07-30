from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import asyncio
from datetime import datetime
import logging

from app.database import connect_to_mongo, close_mongo_connection, get_db
from app.websocket import manager
from app.modules.auth.router import router as auth_router
from app.modules.friends.router import router as friends_router
from app.modules.asks.router import router as asks_router
from app.modules.board.router import router as board_router
from app.seed import router as seed_router

logger = logging.getLogger("uvicorn")

app = FastAPI(title="Campus Ask-Board API", version="1.0.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Periodic task to auto-expire stale asks
async def auto_expiry_loop():
    while True:
        try:
            db = get_db()
            if db is not None:
                now_iso = datetime.utcnow().isoformat()
                # Find asks that have expired but status is still open or locked
                cursor = db.asks.find({
                    "status": {"$in": ["open", "locked"]},
                    "expires_at": {"$lte": now_iso}
                })
                expired_asks = await cursor.to_list(length=100)
                for ask in expired_asks:
                    await db.asks.update_one(
                        {"_id": ask["_id"]},
                        {"$set": {"status": "expired"}}
                    )
                    ask_id_str = str(ask["_id"])
                    await manager.broadcast_board({
                        "event": "BOARD_ASK_EXPIRED",
                        "ask_id": ask_id_str
                    })
        except Exception as e:
            logger.error(f"Error in auto_expiry_loop: {e}")
        await asyncio.sleep(15)  # Check every 15 seconds

@app.on_event("startup")
async def startup_event():
    await connect_to_mongo()
    asyncio.create_task(auto_expiry_loop())

@app.on_event("shutdown")
async def shutdown_event():
    await close_mongo_connection()

# Include Routers
app.include_router(auth_router)
app.include_router(friends_router)
app.include_router(asks_router)
app.include_router(board_router)
app.include_router(seed_router)

@app.get("/api/health")
async def health_check():
    return {"status": "ok", "app": "Campus Ask-Board"}

@app.websocket("/ws/feed/{user_id}")
async def user_feed_websocket(websocket: WebSocket, user_id: str):
    await manager.connect_user(user_id, websocket)
    try:
        while True:
            # Keep connection active
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect_user(user_id, websocket)
    except Exception:
        manager.disconnect_user(user_id, websocket)
