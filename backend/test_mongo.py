import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def test():
    client = AsyncIOMotorClient('mongodb://admin:password@127.0.0.1:27018/?authSource=admin')
    print(await client.server_info())

asyncio.run(test())
