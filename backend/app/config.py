import os

class Settings:
    PROJECT_NAME: str = "Campus Ask-Board"
    MONGO_URI: str = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DB_NAME: str = os.getenv("DB_NAME", "campus_askboard")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "super-secret-campus-askboard-jwt-key-2026")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    ASK_DEFAULT_EXPIRY_MINUTES: int = 20

settings = Settings()
