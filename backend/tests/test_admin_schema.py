import pytest
from pydantic import ValidationError

from app.schemas.admin import AdminInventoryAdjustment, AdminUserStatusUpdate


def test_admin_status_accepts_supported_value() -> None:
    payload = AdminUserStatusUpdate(status="suspended")

    assert payload.status.value == "suspended"


def test_admin_status_rejects_unknown_value() -> None:
    with pytest.raises(ValidationError):
        AdminUserStatusUpdate(status="pending")


def test_inventory_adjustment_rejects_excessive_quantity() -> None:
    with pytest.raises(ValidationError):
        AdminInventoryAdjustment(item_id=1, quantity_delta=10000)
