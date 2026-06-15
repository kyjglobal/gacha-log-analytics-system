from typing import Annotated

from fastapi import APIRouter, Query

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.ranking import RankingResponse
from app.services.ranking_service import RankingService

router = APIRouter()


@router.get("", response_model=RankingResponse)
async def get_rankings(
    session: DbSession,
    current_user: CurrentUser,
    banner_id: Annotated[int | None, Query(ge=1)] = None,
    minimum_draws: Annotated[int, Query(ge=1, le=10000)] = 10,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> RankingResponse:
    return await RankingService(session).rankings(
        current_user_id=current_user.id,
        banner_id=banner_id,
        minimum_draws=minimum_draws,
        limit=limit,
    )
