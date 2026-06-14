from fastapi import APIRouter

from app.api.v1.endpoints import (
    auth,
    community,
    gacha,
    inventory,
    ranking,
    statistics,
    system,
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(community.router, prefix="/community", tags=["community"])
api_router.include_router(gacha.router, prefix="/gacha", tags=["gacha"])
api_router.include_router(inventory.router, prefix="/inventory", tags=["inventory"])
api_router.include_router(ranking.router, prefix="/rankings", tags=["ranking"])
api_router.include_router(
    statistics.router,
    prefix="/statistics",
    tags=["statistics"],
)
api_router.include_router(system.router, prefix="/system", tags=["system"])
