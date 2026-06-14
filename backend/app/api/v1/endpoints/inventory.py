from typing import Annotated

from fastapi import APIRouter, Query

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.gacha import InventoryResponse
from app.services.gacha_service import GachaService

router = APIRouter()


@router.get("", response_model=InventoryResponse)
async def get_inventory(
    session: DbSession,
    current_user: CurrentUser,
    rarity: Annotated[str | None, Query(max_length=20)] = None,
) -> InventoryResponse:
    return await GachaService(session).inventory(
        user_id=current_user.id,
        rarity=rarity,
    )
