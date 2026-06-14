from math import ceil

from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.community import CommunityPost
from app.models.gacha import GachaBanner, GachaSession
from app.models.inventory import Inventory, InventoryTransaction
from app.models.item import Item
from app.models.user import User, Wallet
from app.schemas.admin import (
    AdminDashboardResponse,
    AdminGachaSessionListResponse,
    AdminGachaSessionResponse,
    AdminInventoryAdjustment,
    AdminInventoryAdjustmentResponse,
    AdminUserListResponse,
    AdminUserResponse,
    UserStatus,
)


class AdminService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def dashboard(self) -> AdminDashboardResponse:
        total_users = await self._count(
            select(func.count(User.id)).where(User.is_deleted.is_(False))
        )
        active_users = await self._count(
            select(func.count(User.id)).where(
                User.is_deleted.is_(False),
                User.status == UserStatus.active.value,
            )
        )
        suspended_users = await self._count(
            select(func.count(User.id)).where(
                User.is_deleted.is_(False),
                User.status.in_(
                    [UserStatus.suspended.value, UserStatus.blocked.value]
                ),
            )
        )
        total_draws = await self._count(
            select(func.coalesce(func.sum(GachaSession.draw_count), 0)).where(
                GachaSession.is_deleted.is_(False),
                GachaSession.status == "completed",
            )
        )
        deleted_sessions = await self._count(
            select(func.count(GachaSession.id)).where(
                GachaSession.is_deleted.is_(True)
            )
        )
        posts = await self._count(
            select(func.count(CommunityPost.id)).where(
                CommunityPost.is_deleted.is_(False)
            )
        )
        return AdminDashboardResponse(
            total_users=total_users,
            active_users=active_users,
            suspended_users=suspended_users,
            total_draws=total_draws,
            deleted_gacha_sessions=deleted_sessions,
            total_community_posts=posts,
        )

    async def list_users(
        self,
        *,
        page: int,
        size: int,
        search: str | None,
        user_status: UserStatus | None,
    ) -> AdminUserListResponse:
        filters = [User.is_deleted.is_(False)]
        if search:
            keyword = f"%{search.strip()}%"
            filters.append(
                or_(
                    User.email.ilike(keyword),
                    User.nickname.ilike(keyword),
                )
            )
        if user_status:
            filters.append(User.status == user_status.value)
        total = await self._count(
            select(func.count(User.id)).where(*filters)
        )
        draw_count = (
            select(func.coalesce(func.sum(GachaSession.draw_count), 0))
            .where(
                GachaSession.user_id == User.id,
                GachaSession.is_deleted.is_(False),
                GachaSession.status == "completed",
            )
            .correlate(User)
            .scalar_subquery()
        )
        rows = (
            await self.session.execute(
                select(User, Wallet.balance, draw_count)
                .outerjoin(Wallet, Wallet.user_id == User.id)
                .where(*filters)
                .order_by(User.created_at.desc())
                .offset((page - 1) * size)
                .limit(size)
            )
        ).all()
        return AdminUserListResponse(
            items=[
                AdminUserResponse(
                    id=user.id,
                    email=user.email,
                    nickname=user.nickname,
                    role=user.role,
                    status=user.status,
                    wallet_balance=balance or 0,
                    total_draws=draws or 0,
                    created_at=user.created_at,
                )
                for user, balance, draws in rows
            ],
            page=page,
            size=size,
            total=total,
            pages=ceil(total / size) if total else 0,
        )

    async def update_user_status(
        self,
        *,
        user_id: int,
        new_status: UserStatus,
        current_admin: User,
    ) -> AdminUserResponse:
        if user_id == current_admin.id and new_status != UserStatus.active:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="현재 관리자 계정은 정지하거나 차단할 수 없습니다.",
            )
        user = await self._get_user(user_id, for_update=True)
        user.status = new_status.value
        await self.session.commit()
        await self.session.refresh(user)
        return await self._user_response(user)

    async def list_gacha_sessions(
        self,
        *,
        page: int,
        size: int,
        user_id: int | None,
        include_deleted: bool,
    ) -> AdminGachaSessionListResponse:
        filters = []
        if user_id is not None:
            filters.append(GachaSession.user_id == user_id)
        if not include_deleted:
            filters.append(GachaSession.is_deleted.is_(False))
        total = await self._count(
            select(func.count(GachaSession.id)).where(*filters)
        )
        rows = (
            await self.session.execute(
                select(
                    GachaSession,
                    User.nickname,
                    GachaBanner.name,
                )
                .join(User, User.id == GachaSession.user_id)
                .join(GachaBanner, GachaBanner.id == GachaSession.banner_id)
                .where(*filters)
                .order_by(GachaSession.created_at.desc())
                .offset((page - 1) * size)
                .limit(size)
            )
        ).all()
        return AdminGachaSessionListResponse(
            items=[
                AdminGachaSessionResponse(
                    id=session.id,
                    user_id=session.user_id,
                    user_nickname=nickname,
                    banner_name=banner_name,
                    draw_count=session.draw_count,
                    total_cost=session.total_cost,
                    status=session.status,
                    is_deleted=session.is_deleted,
                    created_at=session.created_at,
                )
                for session, nickname, banner_name in rows
            ],
            page=page,
            size=size,
            total=total,
            pages=ceil(total / size) if total else 0,
        )

    async def delete_gacha_session(self, session_id: int) -> None:
        gacha_session = await self.session.scalar(
            select(GachaSession)
            .where(GachaSession.id == session_id)
            .with_for_update()
        )
        if gacha_session is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="가챠 세션을 찾을 수 없습니다.",
            )
        if gacha_session.is_deleted:
            return
        gacha_session.is_deleted = True
        await self.session.commit()

    async def adjust_inventory(
        self,
        *,
        user_id: int,
        payload: AdminInventoryAdjustment,
        current_admin: User,
    ) -> AdminInventoryAdjustmentResponse:
        if payload.quantity_delta == 0:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="조정 수량은 0일 수 없습니다.",
            )
        await self._get_user(user_id)
        item = await self.session.scalar(
            select(Item).where(Item.id == payload.item_id)
        )
        if item is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="아이템을 찾을 수 없습니다.",
            )
        inventory = await self.session.scalar(
            select(Inventory)
            .where(
                Inventory.user_id == user_id,
                Inventory.item_id == payload.item_id,
            )
            .with_for_update()
        )
        current_quantity = inventory.quantity if inventory else 0
        quantity_after = current_quantity + payload.quantity_delta
        if quantity_after < 0:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="보유 수량보다 많은 아이템을 회수할 수 없습니다.",
            )
        if inventory is None:
            inventory = Inventory(
                user_id=user_id,
                item_id=payload.item_id,
                quantity=quantity_after,
            )
            self.session.add(inventory)
        else:
            inventory.quantity = quantity_after
        await self.session.flush()
        self.session.add(
            InventoryTransaction(
                user_id=user_id,
                item_id=payload.item_id,
                transaction_type="admin_adjustment",
                quantity_delta=payload.quantity_delta,
                quantity_after=quantity_after,
                reference_type="admin_user",
                reference_id=current_admin.id,
            )
        )
        await self.session.commit()
        return AdminInventoryAdjustmentResponse(
            user_id=user_id,
            item_id=item.id,
            item_name=item.name,
            quantity_delta=payload.quantity_delta,
            quantity_after=quantity_after,
        )

    async def _get_user(
        self,
        user_id: int,
        *,
        for_update: bool = False,
    ) -> User:
        statement = select(User).where(
            User.id == user_id,
            User.is_deleted.is_(False),
        )
        if for_update:
            statement = statement.with_for_update()
        user = await self.session.scalar(statement)
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="사용자를 찾을 수 없습니다.",
            )
        return user

    async def _user_response(self, user: User) -> AdminUserResponse:
        balance = (
            await self.session.scalar(
                select(Wallet.balance).where(Wallet.user_id == user.id)
            )
            or 0
        )
        draws = await self._count(
            select(func.coalesce(func.sum(GachaSession.draw_count), 0)).where(
                GachaSession.user_id == user.id,
                GachaSession.is_deleted.is_(False),
                GachaSession.status == "completed",
            )
        )
        return AdminUserResponse(
            id=user.id,
            email=user.email,
            nickname=user.nickname,
            role=user.role,
            status=user.status,
            wallet_balance=balance,
            total_draws=draws,
            created_at=user.created_at,
        )

    async def _count(self, statement) -> int:
        return int(await self.session.scalar(statement) or 0)
