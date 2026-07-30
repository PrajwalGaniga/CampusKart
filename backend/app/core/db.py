import logging
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie

from app.core.config import settings

# Import all models here
from app.models.user import User
from app.models.friend_request import FriendRequest
from app.models.friendship import Friendship
from app.models.ask import Ask
from app.models.reply import Reply
from app.models.notification import Notification
from app.models.session import Session
from app.models.activity_log import ActivityLog
from app.models.category import Category

logger = logging.getLogger(__name__)

async def init_db():
    logger.info("Initializing database connection...")
    client = AsyncIOMotorClient(settings.MONGODB_URI)
    database = client[settings.DATABASE_NAME]
    
    await init_beanie(
        database=database,
        document_models=[
            User,
            FriendRequest,
            Friendship,
            Ask,
            Reply,
            Notification,
            Session,
            ActivityLog,
            Category
        ]
    )
    logger.info("Database initialized successfully.")
