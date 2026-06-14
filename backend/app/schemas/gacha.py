from datetime import datetime

from pydantic import BaseModel, Field


class GachaPoolItemResponse(BaseModel):
    item_id: int
    item_name: str
    rarity: str
    official_probability: float


class GachaBannerResponse(BaseModel):
    id: int
    name: str
    cost_per_draw: int
    pity_threshold: int
    pity_count: int
    wallet_balance: int
    starts_at: datetime
    ends_at: datetime
    pool: list[GachaPoolItemResponse]


class GachaDrawRequest(BaseModel):
    banner_id: int
    count: int = Field(ge=1)


class GachaResultResponse(BaseModel):
    id: int
    item_id: int
    item_name: str
    rarity: str
    sequence: int
    official_probability: float
    applied_probability: float
    random_value: float
    was_pity_applied: bool


class GachaDrawResponse(BaseModel):
    session_id: int
    banner_id: int
    banner_name: str
    draw_count: int
    total_cost: int
    pity_before: int
    pity_after: int
    balance_after: int
    created_at: datetime
    results: list[GachaResultResponse]


class GachaHistoryResponse(BaseModel):
    items: list[GachaDrawResponse]
    page: int
    size: int
    total: int
    pages: int


class InventoryItemResponse(BaseModel):
    item_id: int
    item_name: str
    rarity: str
    image_url: str | None
    quantity: int
    updated_at: datetime


class InventoryResponse(BaseModel):
    items: list[InventoryItemResponse]
    total_unique_items: int
    total_quantity: int
