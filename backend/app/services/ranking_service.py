from datetime import UTC, datetime
from decimal import Decimal

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.gacha import (
    GachaBanner,
    GachaPoolItem,
    GachaResult,
    GachaSession,
)
from app.models.item import Item
from app.models.user import User
from app.schemas.ranking import RankingEntryResponse, RankingResponse
from app.services.statistics_service import RARITY_WEIGHTS, StatisticsService


class RankingService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def rankings(
        self,
        *,
        current_user_id: int,
        banner_id: int | None,
        minimum_draws: int,
        limit: int,
    ) -> RankingResponse:
        banner = await self._get_banner(banner_id)
        official = await self._official_probabilities(banner.id)
        user_results = await self._user_result_counts(banner.id)
        ranked = self._build_ranked_entries(
            user_results=user_results,
            official=official,
            current_user_id=current_user_id,
            minimum_draws=minimum_draws,
        )
        my_entry = next(
            (entry for entry in ranked if entry.user_id == current_user_id),
            None,
        )
        return RankingResponse(
            banner_id=banner.id,
            banner_name=banner.name,
            minimum_draws=minimum_draws,
            entries=ranked[:limit],
            my_rank=my_entry.rank if my_entry else None,
        )

    async def _get_banner(self, banner_id: int | None) -> GachaBanner:
        statement = select(GachaBanner)
        if banner_id is None:
            now = datetime.now(UTC).replace(tzinfo=None)
            statement = statement.where(
                GachaBanner.is_active.is_(True),
                GachaBanner.starts_at <= now,
                GachaBanner.ends_at >= now,
            )
        else:
            statement = statement.where(GachaBanner.id == banner_id)
        banner = await self.session.scalar(statement.order_by(GachaBanner.id))
        if banner is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="랭킹을 조회할 가챠 배너를 찾을 수 없습니다.",
            )
        return banner

    async def _official_probabilities(
        self,
        banner_id: int,
    ) -> dict[str, Decimal]:
        rows = (
            await self.session.execute(
                select(
                    Item.rarity,
                    func.sum(GachaPoolItem.base_probability),
                )
                .join(Item, Item.id == GachaPoolItem.item_id)
                .where(GachaPoolItem.banner_id == banner_id)
                .group_by(Item.rarity)
            )
        ).all()
        return {rarity: probability for rarity, probability in rows}

    async def _user_result_counts(
        self,
        banner_id: int,
    ) -> dict[int, tuple[str, dict[str, int]]]:
        rows = (
            await self.session.execute(
                select(
                    User.id,
                    User.nickname,
                    Item.rarity,
                    func.count(GachaResult.id),
                )
                .join(GachaSession, GachaSession.user_id == User.id)
                .join(GachaResult, GachaResult.session_id == GachaSession.id)
                .join(Item, Item.id == GachaResult.item_id)
                .where(
                    User.is_deleted.is_(False),
                    User.status == "active",
                    GachaSession.banner_id == banner_id,
                    GachaSession.status == "completed",
                    GachaSession.is_deleted.is_(False),
                )
                .group_by(User.id, User.nickname, Item.rarity)
            )
        ).all()
        results: dict[int, tuple[str, dict[str, int]]] = {}
        for user_id, nickname, rarity, count in rows:
            if user_id not in results:
                results[user_id] = (nickname, {})
            results[user_id][1][rarity] = count
        return results

    @staticmethod
    def _build_ranked_entries(
        *,
        user_results: dict[int, tuple[str, dict[str, int]]],
        official: dict[str, Decimal],
        current_user_id: int,
        minimum_draws: int,
    ) -> list[RankingEntryResponse]:
        candidates: list[tuple[int, str, int, int, float, float]] = []
        for user_id, (nickname, counts) in user_results.items():
            total = sum(counts.values())
            if total < minimum_draws:
                continue
            mythic_count = counts.get("mythic", 0)
            candidates.append(
                (
                    user_id,
                    nickname,
                    total,
                    mythic_count,
                    mythic_count / total,
                    StatisticsService._luck_score(official, counts),
                )
            )
        candidates.sort(key=lambda row: (-row[5], -row[2], row[0]))
        return [
            RankingEntryResponse(
                rank=index,
                user_id=user_id,
                nickname=nickname,
                total_draws=total,
                mythic_count=mythic_count,
                mythic_probability=mythic_probability,
                luck_score=luck_score,
                is_current_user=user_id == current_user_id,
            )
            for index, (
                user_id,
                nickname,
                total,
                mythic_count,
                mythic_probability,
                luck_score,
            ) in enumerate(candidates, start=1)
        ]
