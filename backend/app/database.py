from motor.motor_asyncio import AsyncIOMotorClient
from app.config import settings
import logging

logger = logging.getLogger("uvicorn")

class Database:
    client: AsyncIOMotorClient = None
    db = None

db = Database()

async def connect_to_mongo():
    logger.info(f"Connecting to MongoDB at {settings.MONGO_URI}...")
    db.client = AsyncIOMotorClient(settings.MONGO_URI)
    db.db = db.client[settings.DB_NAME]
    
    # Ensure indexes
    await db.db.users.create_index("username", unique=True)
    await db.db.users.create_index("email", unique=True)
    await db.db.friend_edges.create_index([("user_id", 1), ("friend_id", 1)], unique=True)
    await db.db.asks.create_index([("requester_id", 1), ("created_at", -1)])
    await db.db.asks.create_index("expires_at")
    await db.db.replies.create_index([("ask_id", 1)])
    
    logger.info("Connected to MongoDB successfully and indexes created.")

async def close_mongo_connection():
    if db.client:
        db.client.close()
        logger.info("Closed MongoDB connection.")

def get_db():
    return db.db
