from decimal import Decimal

import pytest
from fastapi import HTTPException

from app.models.gacha import GachaPoolItem
from app.models.item import Item
from app.services.gacha_service import GachaService


def _pool_entry(
    *,
    item_id: int,
    rarity: str,
    probability: str,
) -> tuple[GachaPoolItem, Item]:
    return (
        GachaPoolItem(
            id=item_id,
            banner_id=1,
            item_id=item_id,
            base_probability=Decimal(probability),
            pickup_weight=Decimal("1"),
        ),
        Item(
            id=item_id,
            code=f"ITEM_{item_id}",
            name=f"Item {item_id}",
            rarity=rarity,
            description=None,
            image_url=None,
            is_active=True,
        ),
    )


def test_validate_pool_accepts_probability_sum_of_one() -> None:
    pool = [
        _pool_entry(item_id=1, rarity="mythic", probability="0.012"),
        _pool_entry(item_id=2, rarity="common", probability="0.988"),
    ]

    GachaService._validate_pool(pool)


def test_validate_pool_rejects_invalid_probability_sum() -> None:
    pool = [
        _pool_entry(item_id=1, rarity="mythic", probability="0.012"),
        _pool_entry(item_id=2, rarity="common", probability="0.500"),
    ]

    with pytest.raises(HTTPException) as exc_info:
        GachaService._validate_pool(pool)

    assert exc_info.value.status_code == 409


def test_select_item_uses_probability_boundaries() -> None:
    pool = [
        _pool_entry(item_id=1, rarity="mythic", probability="0.012"),
        _pool_entry(item_id=2, rarity="common", probability="0.988"),
    ]
    service = GachaService(session=None)  # type: ignore[arg-type]

    _, first_item = service._select_item(
        pool,
        roll=Decimal("0.01199999"),
        pity_applied=False,
    )
    _, second_item = service._select_item(
        pool,
        roll=Decimal("0.01200000"),
        pity_applied=False,
    )

    assert first_item.id == 1
    assert second_item.id == 2


def test_select_item_limits_pity_draw_to_mythic_pool() -> None:
    pool = [
        _pool_entry(item_id=1, rarity="mythic", probability="0.012"),
        _pool_entry(item_id=2, rarity="common", probability="0.988"),
    ]
    service = GachaService(session=None)  # type: ignore[arg-type]

    _, selected_item = service._select_item(
        pool,
        roll=Decimal("0.99999999"),
        pity_applied=True,
    )

    assert selected_item.rarity == "mythic"
