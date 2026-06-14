from typing import Annotated

from fastapi import APIRouter, Query

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.statistics import ProbabilityStatisticsResponse
from app.services.statistics_service import StatisticsService

router = APIRouter()


@router.get("/me", response_model=ProbabilityStatisticsResponse)
async def get_my_statistics(
    session: DbSession,
    current_user: CurrentUser,
    banner_id: Annotated[int | None, Query(ge=1)] = None,
) -> ProbabilityStatisticsResponse:
    return await StatisticsService(session).probability_statistics(
        user_id=current_user.id,
        banner_id=banner_id,
    )
