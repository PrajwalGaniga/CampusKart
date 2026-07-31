# pyrefly: ignore [missing-import]
from beanie import Document
import pymongo
from pymongo import IndexModel, ASCENDING

class Category(Document):
    name: str
    icon: str
    color: str

    class Settings:
        name = "categories"
        indexes = [
            IndexModel([("name", ASCENDING)], unique=True)
        ]