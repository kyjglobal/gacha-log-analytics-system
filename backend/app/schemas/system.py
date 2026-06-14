from pydantic import BaseModel


class SystemStatus(BaseModel):
    status: str
    database: str
