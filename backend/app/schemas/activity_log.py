from pydantic import BaseModel
from datetime import datetime
from typing import Dict, Any

class ActivityLogResponse(BaseModel):
    id: str
    user_id: str
    action: str
    metadata: Dict[str, Any]
    created_at: datetime
    
    class Config:
        from_attributes = True
