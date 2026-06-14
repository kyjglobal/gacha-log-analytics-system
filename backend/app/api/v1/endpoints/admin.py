from typing import Annotated

from fastapi import APIRouter, Query, Response, status

from app.core.dependencies import CurrentAdmin, DbSession
from app.schemas.admin import (
    AdminDashboardResponse,
    AdminGachaSessionListResponse,
    AdminInventoryAdjustment,
    AdminInventoryAdjustmentResponse,
    AdminUserListResponse,
    AdminUserResponse,
    AdminUserStatusUpdate,
    UserStatus,
)
from app.services.admin_service import AdminService

router = APIRouter()


@router.get("/dashboard", response_model=AdminDashboardResponse)
async def dashboard(
    session: DbSession,
    _: CurrentAdmin,
) -> AdminDashboardResponse:
    return await AdminService(session).dashboard()


@router.get("/users", response_model=AdminUserListResponse)
async def list_users(
    session: DbSession,
    _: CurrentAdmin,
    page: Annotated[int, Query(ge=1)] = 1,
    size: Annotated[int, Query(ge=1, le=100)] = 20,
    search: Annotated[str | None, Query(max_length=100)] = None,
    user_status: UserStatus | None = None,
) -> AdminUserListResponse:
    return await AdminService(session).list_users(
        page=page,
        size=size,
        search=search,
        user_status=user_status,
    )


@router.patch("/users/{user_id}/status", response_model=AdminUserResponse)
async def update_user_status(
    user_id: int,
    payload: AdminUserStatusUpdate,
    session: DbSession,
    current_admin: CurrentAdmin,
) -> AdminUserResponse:
    return await AdminService(session).update_user_status(
        user_id=user_id,
        new_status=payload.status,
        current_admin=current_admin,
    )


@router.post(
    "/users/{user_id}/inventory-adjustments",
    response_model=AdminInventoryAdjustmentResponse,
)
async def adjust_inventory(
    user_id: int,
    payload: AdminInventoryAdjustment,
    session: DbSession,
    current_admin: CurrentAdmin,
) -> AdminInventoryAdjustmentResponse:
    return await AdminService(session).adjust_inventory(
        user_id=user_id,
        payload=payload,
        current_admin=current_admin,
    )


@router.get("/gacha-sessions", response_model=AdminGachaSessionListResponse)
async def list_gacha_sessions(
    session: DbSession,
    _: CurrentAdmin,
    page: Annotated[int, Query(ge=1)] = 1,
    size: Annotated[int, Query(ge=1, le=100)] = 20,
    user_id: Annotated[int | None, Query(ge=1)] = None,
    include_deleted: bool = False,
) -> AdminGachaSessionListResponse:
    return await AdminService(session).list_gacha_sessions(
        page=page,
        size=size,
        user_id=user_id,
        include_deleted=include_deleted,
    )


@router.delete(
    "/gacha-sessions/{session_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_gacha_session(
    session_id: int,
    session: DbSession,
    _: CurrentAdmin,
) -> Response:
    await AdminService(session).delete_gacha_session(session_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
