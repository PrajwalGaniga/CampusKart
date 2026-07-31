from beanie import Document # pyright: ignore[reportMissingImports]
import pymongo # pyright: ignore[reportMissingImports]
from pymongo import IndexModel, ASCENDING # pyright: ignore[reportMissingImports] 

class Category(Document):
    name: str
    icon: str
    color: str

    class Settings:
        name = "categories"
        indexes = [
            IndexModel([("name", ASCENDING)], unique=True)
        ]