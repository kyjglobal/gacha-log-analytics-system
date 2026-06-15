import random
from collections.abc import Callable
from datetime import UTC, datetime
from decimal import Decimal, ROUND_DOWN
from math import ceil

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.gacha import (
    GachaBanner,
    GachaPoolItem,
    GachaResult,
    GachaSession,
)
from app.models.inventory import Inventory, InventoryTransaction
from app.models.item import Item
from app.models.user import UserPityState, Wallet, WalletTransaction
from app.schemas.gacha import (
    GachaBannerResponse,
    GachaDrawResponse,
    GachaHistoryResponse,
    GachaPoolItemResponse,
    GachaResultResponse,
    InventoryItemResponse,
    InventoryResponse,
)

RandomSource = Callable[[], float]
EIGHT_PLACES = Decimal("0.00000001")


class GachaService:
    """Coordinates wallet, draw logs, inventory, and pity in one transaction."""

    def __init__(
        self,
        session: AsyncSession,
        *,
        random_source: RandomSource | None = None,
    ) -> None:
        self.session = session
        secure_random = random.SystemRandom()
        self.random_source = random_source or secure_random.random

    async def list_banners(self, user_id: int) -> list[GachaBannerResponse]:
        now = datetime.now(UTC).replace(tzinfo=None)
        banners = (
            await self.session.scalars(
                select(GachaBanner)
                .where(
                    GachaBanner.is_active.is_(True),
                    GachaBanner.starts_at <= now,
                    GachaBanner.ends_at >= now,
                )
                .order_by(GachaBanner.id)
            )
        ).all()
        wallet_balance = (
            await self.session.scalar(
                select(Wallet.balance).where(Wallet.user_id == user_id)
            )
            or 0
        )
        responses: list[GachaBannerResponse] = []
        for banner in banners:
            pool = await self._load_pool(banner.id)
            pity_count = (
                await self.session.scalar(
                    select(UserPityState.draw_count).where(
                        UserPityState.user_id == user_id,
                        UserPityState.banner_id == banner.id,
                    )
                )
                or 0
            )
            responses.append(
                GachaBannerResponse(
                    id=banner.id,
                    name=banner.name,
                    cost_per_draw=banner.cost_per_draw,
                    pity_threshold=banner.pity_threshold,
                    pity_count=pity_count,
                    wallet_balance=wallet_balance,
                    starts_at=banner.starts_at,
                    ends_at=banner.ends_at,
                    pool=[
                        GachaPoolItemResponse(
                            item_id=item.id,
                            item_name=item.name,
                            rarity=item.rarity,
                            official_probability=float(pool_item.base_probability),
                        )
                        for pool_item, item in pool
                    ],
                )
            )
        return responses

    async def draw(
        self,
        *,
        user_id: int,
        banner_id: int,
        count: int,
        idempotency_key: str,
    ) -> GachaDrawResponse:
        if count not in (1, 10):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="가챠 횟수는 1회 또는 10회만 가능합니다.",
            )

        existing_session_id = await self.session.scalar(
            select(GachaSession.id).where(
                GachaSession.user_id == user_id,
                GachaSession.idempotency_key == idempotency_key,
            )
        )
        if existing_session_id is not None:
            return await self._load_draw_response(existing_session_id, user_id)

        try:
            banner = await self._get_active_banner(banner_id)
            pool = await self._load_pool(banner_id)
            self._validate_pool(pool)

            wallet = await self.session.scalar(
                select(Wallet)
                .where(Wallet.user_id == user_id)
                .with_for_update()
            )
            if wallet is None:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="사용자 지갑이 존재하지 않습니다.",
                )

            total_cost = banner.cost_per_draw * count
            if wallet.balance < total_cost:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="보유 재화가 부족합니다.",
                )

            pity_state = await self.session.scalar(
                select(UserPityState)
                .where(
                    UserPityState.user_id == user_id,
                    UserPityState.banner_id == banner_id,
                )
                .with_for_update()
            )
            if pity_state is None:
                pity_state = UserPityState(
                    user_id=user_id,
                    banner_id=banner_id,
                    draw_count=0,
                    correction_rate=Decimal("0"),
                )
                self.session.add(pity_state)
                await self.session.flush()

            pity_before = pity_state.draw_count
            wallet.balance -= total_cost
            wallet.version += 1

            gacha_session = GachaSession(
                user_id=user_id,
                banner_id=banner_id,
                idempotency_key=idempotency_key,
                draw_count=count,
                total_cost=total_cost,
                pity_before=pity_before,
                pity_after=pity_before,
            )
            self.session.add(gacha_session)
            await self.session.flush()

            results: list[tuple[GachaResult, Item]] = []
            for sequence in range(1, count + 1):
                pity_applied = pity_state.draw_count + 1 >= banner.pity_threshold
                roll = self._decimal_random()
                pool_item, item = self._select_item(
                    pool,
                    roll=roll,
                    pity_applied=pity_applied,
                )
                applied_probability = (
                    Decimal("1") if pity_applied else pool_item.base_probability
                )
                result = GachaResult(
                    session_id=gacha_session.id,
                    item_id=item.id,
                    sequence=sequence,
                    base_probability=pool_item.base_probability,
                    applied_probability=applied_probability,
                    random_value=roll,
                    was_pity_applied=pity_applied,
                )
                self.session.add(result)
                await self.session.flush()
                results.append((result, item))

                inventory = await self.session.scalar(
                    select(Inventory)
                    .where(
                        Inventory.user_id == user_id,
                        Inventory.item_id == item.id,
                    )
                    .with_for_update()
                )
                if inventory is None:
                    inventory = Inventory(
                        user_id=user_id,
                        item_id=item.id,
                        quantity=1,
                    )
                    self.session.add(inventory)
                else:
                    inventory.quantity += 1
                await self.session.flush()
                self.session.add(
                    InventoryTransaction(
                        user_id=user_id,
                        item_id=item.id,
                        transaction_type="gacha_acquire",
                        quantity_delta=1,
                        quantity_after=inventory.quantity,
                        reference_type="gacha_session",
                        reference_id=gacha_session.id,
                    )
                )

                if item.rarity == "mythic":
                    pity_state.draw_count = 0
                else:
                    pity_state.draw_count += 1

            gacha_session.pity_after = pity_state.draw_count
            self.session.add(
                WalletTransaction(
                    user_id=user_id,
                    transaction_type="gacha_spend",
                    amount=-total_cost,
                    balance_after=wallet.balance,
                    reference_type="gacha_session",
                    reference_id=gacha_session.id,
                )
            )
            await self.session.commit()
            await self.session.refresh(gacha_session)
            return self._build_draw_response(
                gacha_session,
                banner,
                wallet.balance,
                results,
            )
        except IntegrityError:
            await self.session.rollback()
            existing_session_id = await self.session.scalar(
                select(GachaSession.id).where(
                    GachaSession.user_id == user_id,
                    GachaSession.idempotency_key == idempotency_key,
                )
            )
            if existing_session_id is not None:
                return await self._load_draw_response(existing_session_id, user_id)
            raise
        except HTTPException:
            await self.session.rollback()
            raise
        except Exception:
            await self.session.rollback()
            raise

    async def history(
        self,
        *,
        user_id: int,
        page: int,
        size: int,
    ) -> GachaHistoryResponse:
        filters = [
            GachaSession.user_id == user_id,
            GachaSession.is_deleted.is_(False),
        ]
        total = (
            await self.session.scalar(
                select(func.count(GachaSession.id)).where(*filters)
            )
            or 0
        )
        session_ids = (
            await self.session.scalars(
                select(GachaSession.id)
                .where(*filters)
                .order_by(GachaSession.created_at.desc())
                .offset((page - 1) * size)
                .limit(size)
            )
        ).all()
        items = [
            await self._load_draw_response(session_id, user_id)
            for session_id in session_ids
        ]
        return GachaHistoryResponse(
            items=items,
            page=page,
            size=size,
            total=total,
            pages=ceil(total / size) if total else 0,
        )

    async def inventory(
        self,
        *,
        user_id: int,
        rarity: str | None = None,
    ) -> InventoryResponse:
        statement = (
            select(Inventory, Item)
            .join(Item, Item.id == Inventory.item_id)
            .where(Inventory.user_id == user_id, Inventory.quantity > 0)
            .order_by(Item.rarity, Item.name)
        )
        if rarity:
            statement = statement.where(Item.rarity == rarity)
        rows = (await self.session.execute(statement)).all()
        items = [
            InventoryItemResponse(
                item_id=item.id,
                item_name=item.name,
                rarity=item.rarity,
                image_url=item.image_url,
                quantity=inventory.quantity,
                updated_at=inventory.updated_at,
            )
            for inventory, item in rows
        ]
        return InventoryResponse(
            items=items,
            total_unique_items=len(items),
            total_quantity=sum(item.quantity for item in items),
        )

    async def _get_active_banner(self, banner_id: int) -> GachaBanner:
        now = datetime.now(UTC).replace(tzinfo=None)
        banner = await self.session.scalar(
            select(GachaBanner).where(
                GachaBanner.id == banner_id,
                GachaBanner.is_active.is_(True),
                GachaBanner.starts_at <= now,
                GachaBanner.ends_at >= now,
            )
        )
        if banner is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="활성 가챠 배너를 찾을 수 없습니다.",
            )
        return banner

    async def _load_pool(
        self,
        banner_id: int,
    ) -> list[tuple[GachaPoolItem, Item]]:
        return list(
            (
                await self.session.execute(
                    select(GachaPoolItem, Item)
                    .join(Item, Item.id == GachaPoolItem.item_id)
                    .where(
                        GachaPoolItem.banner_id == banner_id,
                        Item.is_active.is_(True),
                    )
                    .order_by(GachaPoolItem.id)
                )
            ).all()
        )

    @staticmethod
    def _validate_pool(pool: list[tuple[GachaPoolItem, Item]]) -> None:
        if not pool:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="가챠 확률 풀이 비어 있습니다.",
            )
        total = sum(
            (pool_item.base_probability for pool_item, _ in pool),
            Decimal("0"),
        )
        if abs(total - Decimal("1")) > EIGHT_PLACES:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="가챠 공식 확률의 합이 1이 아닙니다.",
            )

    def _select_item(
        self,
        pool: list[tuple[GachaPoolItem, Item]],
        *,
        roll: Decimal,
        pity_applied: bool,
    ) -> tuple[GachaPoolItem, Item]:
        candidates = (
            [entry for entry in pool if entry[1].rarity == "mythic"]
            if pity_applied
            else pool
        )
        if not candidates:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="천장 적용 가능한 신화 아이템이 없습니다.",
            )
        total_weight = sum(
            (
                pool_item.base_probability * pool_item.pickup_weight
                for pool_item, _ in candidates
            ),
            Decimal("0"),
        )
        target = roll * total_weight
        cumulative = Decimal("0")
        for pool_item, item in candidates:
            cumulative += pool_item.base_probability * pool_item.pickup_weight
            if target < cumulative:
                return pool_item, item
        return candidates[-1]

    def _decimal_random(self) -> Decimal:
        return Decimal(str(self.random_source())).quantize(
            EIGHT_PLACES,
            rounding=ROUND_DOWN,
        )

    async def _load_draw_response(
        self,
        session_id: int,
        user_id: int,
    ) -> GachaDrawResponse:
        row = (
            await self.session.execute(
                select(GachaSession, GachaBanner)
                .join(GachaBanner, GachaBanner.id == GachaSession.banner_id)
                .where(
                    GachaSession.id == session_id,
                    GachaSession.user_id == user_id,
                    GachaSession.is_deleted.is_(False),
                )
            )
        ).one_or_none()
        if row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="가챠 이력을 찾을 수 없습니다.",
            )
        gacha_session, banner = row
        result_rows = (
            await self.session.execute(
                select(GachaResult, Item)
                .join(Item, Item.id == GachaResult.item_id)
                .where(GachaResult.session_id == session_id)
                .order_by(GachaResult.sequence)
            )
        ).all()
        balance = await self.session.scalar(
            select(WalletTransaction.balance_after).where(
                WalletTransaction.user_id == user_id,
                WalletTransaction.reference_type == "gacha_session",
                WalletTransaction.reference_id == session_id,
            )
        )
        if balance is None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="가챠 재화 거래 로그를 찾을 수 없습니다.",
            )
        return self._build_draw_response(
            gacha_session,
            banner,
            balance,
            list(result_rows),
        )

    @staticmethod
    def _build_draw_response(
        gacha_session: GachaSession,
        banner: GachaBanner,
        balance_after: int,
        results: list[tuple[GachaResult, Item]],
    ) -> GachaDrawResponse:
        return GachaDrawResponse(
            session_id=gacha_session.id,
            banner_id=banner.id,
            banner_name=banner.name,
            draw_count=gacha_session.draw_count,
            total_cost=gacha_session.total_cost,
            pity_before=gacha_session.pity_before,
            pity_after=gacha_session.pity_after,
            balance_after=balance_after,
            created_at=gacha_session.created_at,
            results=[
                GachaResultResponse(
                    id=result.id,
                    item_id=item.id,
                    item_name=item.name,
                    rarity=item.rarity,
                    sequence=result.sequence,
                    official_probability=float(result.base_probability),
                    applied_probability=float(result.applied_probability),
                    random_value=float(result.random_value),
                    was_pity_applied=result.was_pity_applied,
                )
                for result, item in results
            ],
        )
