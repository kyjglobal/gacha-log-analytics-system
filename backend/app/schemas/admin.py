from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, Field


class UserStatus(StrEnum):
    active = "active"
    suspended = "suspended"
    blocked = "blocked"


class AdminDashboardResponse(BaseModel):
    total_users: int
    active_users: int
    suspended_users: int
    total_draws: int
    deleted_gacha_sessions: int
    total_community_posts: int


class AdminUserResponse(BaseModel):
    id: int
    email: str
    nickname: str
    role: str
    status: str
    wallet_balance: int
    total_draws: int
    created_at: datetime


class AdminUserListResponse(BaseModel):
    items: list[AdminUserResponse]
    page: int
    size: int
    total: int
    pages: int


class AdminUserStatusUpdate(BaseModel):
    status: UserStatus


class AdminGachaSessionResponse(BaseModel):
    id: int
    user_id: int
    user_nickname: str
    banner_name: str
    draw_count: int
    total_cost: int
    status: str
    is_deleted: bool
    created_at: datetime


class AdminGachaSessionListResponse(BaseModel):
    items: list[AdminGachaSessionResponse]
    page: int
    size: int
    total: int
    pages: int


class AdminInventoryAdjustment(BaseModel):
    item_id: int = Field(ge=1)
    quantity_delta: int = Field(ge=-9999, le=9999)


class AdminInventoryAdjustmentResponse(BaseModel):
    user_id: int
    item_id: int
    item_name: str
    quantity_delta: int
    quantity_after: int
