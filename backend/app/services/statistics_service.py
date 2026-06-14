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
from app.schemas.statistics import (
    ProbabilityStatisticsResponse,
    RarityStatisticResponse,
)

RARITY_ORDER = ("mythic", "legendary", "epic", "rare", "common")
RARITY_WEIGHTS = {
    "mythic": Decimal("100"),
    "legendary": Decimal("20"),
    "epic": Decimal("5"),
    "rare": Decimal("2"),
    "common": Decimal("1"),
}


class StatisticsService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def probability_statistics(
        self,
        *,
        user_id: int,
        banner_id: int | None,
    ) -> ProbabilityStatisticsResponse:
        banner = await self._get_banner(banner_id)
        official = await self._official_probabilities(banner.id)
        personal_counts = await self._result_counts(
            banner_id=banner.id,
            user_id=user_id,
        )
        community_counts = await self._result_counts(
            banner_id=banner.id,
            user_id=None,
        )
        personal_total = sum(personal_counts.values())
        community_total = sum(community_counts.values())

        rarities = [
            RarityStatisticResponse(
                rarity=rarity,
                official_probability=float(official.get(rarity, Decimal("0"))),
                personal_count=personal_counts.get(rarity, 0),
                personal_probability=self._rate(
                    personal_counts.get(rarity, 0),
                    personal_total,
                ),
                personal_deviation=self._rate(
                    personal_counts.get(rarity, 0),
                    personal_total,
                )
                - float(official.get(rarity, Decimal("0"))),
                community_count=community_counts.get(rarity, 0),
                community_probability=self._rate(
                    community_counts.get(rarity, 0),
                    community_total,
                ),
            )
            for rarity in RARITY_ORDER
        ]

        return ProbabilityStatisticsResponse(
            banner_id=banner.id,
            banner_name=banner.name,
            personal_total_draws=personal_total,
            community_total_draws=community_total,
            luck_score=self._luck_score(official, personal_counts),
            rarities=rarities,
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
                detail="통계를 조회할 가챠 배너를 찾을 수 없습니다.",
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

    async def _result_counts(
        self,
        *,
        banner_id: int,
        user_id: int | None,
    ) -> dict[str, int]:
        filters = [
            GachaSession.banner_id == banner_id,
            GachaSession.status == "completed",
            GachaSession.is_deleted.is_(False),
        ]
        if user_id is not None:
            filters.append(GachaSession.user_id == user_id)
        rows = (
            await self.session.execute(
                select(Item.rarity, func.count(GachaResult.id))
                .join(Item, Item.id == GachaResult.item_id)
                .join(
                    GachaSession,
                    GachaSession.id == GachaResult.session_id,
                )
                .where(*filters)
                .group_by(Item.rarity)
            )
        ).all()
        return {rarity: count for rarity, count in rows}

    @staticmethod
    def _rate(count: int, total: int) -> float:
        return count / total if total else 0.0

    @staticmethod
    def _luck_score(
        official: dict[str, Decimal],
        personal_counts: dict[str, int],
    ) -> float:
        total = sum(personal_counts.values())
        if total == 0:
            return 0.0
        expected_weight = sum(
            official.get(rarity, Decimal("0")) * weight
            for rarity, weight in RARITY_WEIGHTS.items()
        )
        if expected_weight == 0:
            return 0.0
        observed_weight = sum(
            Decimal(personal_counts.get(rarity, 0))
            / Decimal(total)
            * weight
            for rarity, weight in RARITY_WEIGHTS.items()
        )
        return round(float(observed_weight / expected_weight * 100), 2)
