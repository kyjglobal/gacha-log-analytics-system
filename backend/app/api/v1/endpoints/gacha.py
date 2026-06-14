from typing import Annotated

from fastapi import APIRouter, Header, Query

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.gacha import (
    GachaBannerResponse,
    GachaDrawRequest,
    GachaDrawResponse,
    GachaHistoryResponse,
)
from app.services.gacha_service import GachaService

router = APIRouter()


@router.get("/banners", response_model=list[GachaBannerResponse])
async def list_banners(
    session: DbSession,
    current_user: CurrentUser,
) -> list[GachaBannerResponse]:
    return await GachaService(session).list_banners(current_user.id)


@router.post("/draw", response_model=GachaDrawResponse)
async def draw(
    payload: GachaDrawRequest,
    session: DbSession,
    current_user: CurrentUser,
    idempotency_key: Annotated[
        str,
        Header(alias="Idempotency-Key", min_length=8, max_length=64),
    ],
) -> GachaDrawResponse:
    return await GachaService(session).draw(
        user_id=current_user.id,
        banner_id=payload.banner_id,
        count=payload.count,
        idempotency_key=idempotency_key,
    )


@router.get("/history", response_model=GachaHistoryResponse)
async def history(
    session: DbSession,
    current_user: CurrentUser,
    page: Annotated[int, Query(ge=1)] = 1,
    size: Annotated[int, Query(ge=1, le=50)] = 20,
) -> GachaHistoryResponse:
    return await GachaService(session).history(
        user_id=current_user.id,
        page=page,
        size=size,
    )
