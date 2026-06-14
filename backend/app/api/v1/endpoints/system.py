from fastapi import APIRouter

from app.schemas.system import SystemStatus

router = APIRouter()


@router.get("/status", response_model=SystemStatus)
async def get_system_status() -> SystemStatus:
    return SystemStatus(status="operational", database="configured")
