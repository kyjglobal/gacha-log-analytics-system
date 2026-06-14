"""seed initial gacha catalog

Revision ID: 0002_seed_gacha_catalog
Revises: 0001_initial_schema
Create Date: 2026-06-15
"""

from typing import Sequence, Union
from datetime import datetime

import sqlalchemy as sa
from alembic import op

revision: str = "0002_seed_gacha_catalog"
down_revision: Union[str, None] = "0001_initial_schema"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    items = sa.table(
        "items",
        sa.column("id", sa.BigInteger()),
        sa.column("code", sa.String()),
        sa.column("name", sa.String()),
        sa.column("rarity", sa.String()),
        sa.column("description", sa.String()),
        sa.column("image_url", sa.String()),
        sa.column("is_active", sa.Boolean()),
    )
    banners = sa.table(
        "gacha_banners",
        sa.column("id", sa.BigInteger()),
        sa.column("name", sa.String()),
        sa.column("cost_per_draw", sa.BigInteger()),
        sa.column("pity_threshold", sa.Integer()),
        sa.column("starts_at", sa.DateTime()),
        sa.column("ends_at", sa.DateTime()),
        sa.column("is_active", sa.Boolean()),
    )
    pool_items = sa.table(
        "gacha_pool_items",
        sa.column("id", sa.BigInteger()),
        sa.column("banner_id", sa.BigInteger()),
        sa.column("item_id", sa.BigInteger()),
        sa.column("base_probability", sa.Numeric(10, 8)),
        sa.column("pickup_weight", sa.Numeric(10, 8)),
    )

    op.bulk_insert(
        items,
        [
            {
                "id": 1,
                "code": "ASTRA_CROWN",
                "name": "Astra Crown",
                "rarity": "mythic",
                "description": "천공의 힘이 깃든 신화 아이템",
                "image_url": None,
                "is_active": True,
            },
            {
                "id": 2,
                "code": "ABYSS_CODEX",
                "name": "Abyss Codex",
                "rarity": "legendary",
                "description": "심연의 지식을 담은 전설 아이템",
                "image_url": None,
                "is_active": True,
            },
            {
                "id": 3,
                "code": "STARBLADE",
                "name": "Starblade",
                "rarity": "epic",
                "description": "별빛으로 단련된 영웅 아이템",
                "image_url": None,
                "is_active": True,
            },
            {
                "id": 4,
                "code": "SPIRIT_RING",
                "name": "Spirit Ring",
                "rarity": "rare",
                "description": "정령의 힘이 담긴 희귀 아이템",
                "image_url": None,
                "is_active": True,
            },
            {
                "id": 5,
                "code": "MANA_POTION",
                "name": "Mana Potion",
                "rarity": "common",
                "description": "기본 마력 회복 아이템",
                "image_url": None,
                "is_active": True,
            },
        ],
    )
    op.bulk_insert(
        banners,
        [
            {
                "id": 1,
                "name": "Celestial Trace",
                "cost_per_draw": 160,
                "pity_threshold": 80,
                "starts_at": datetime(2026, 1, 1, 0, 0, 0),
                "ends_at": datetime(2099, 12, 31, 23, 59, 59),
                "is_active": True,
            }
        ],
    )
    op.bulk_insert(
        pool_items,
        [
            {
                "id": 1,
                "banner_id": 1,
                "item_id": 1,
                "base_probability": "0.01200000",
                "pickup_weight": "1.00000000",
            },
            {
                "id": 2,
                "banner_id": 1,
                "item_id": 2,
                "base_probability": "0.05000000",
                "pickup_weight": "1.00000000",
            },
            {
                "id": 3,
                "banner_id": 1,
                "item_id": 3,
                "base_probability": "0.15000000",
                "pickup_weight": "1.00000000",
            },
            {
                "id": 4,
                "banner_id": 1,
                "item_id": 4,
                "base_probability": "0.30000000",
                "pickup_weight": "1.00000000",
            },
            {
                "id": 5,
                "banner_id": 1,
                "item_id": 5,
                "base_probability": "0.48800000",
                "pickup_weight": "1.00000000",
            },
        ],
    )


def downgrade() -> None:
    op.execute("DELETE FROM gacha_pool_items WHERE banner_id = 1")
    op.execute("DELETE FROM gacha_banners WHERE id = 1")
    op.execute("DELETE FROM items WHERE id BETWEEN 1 AND 5")
