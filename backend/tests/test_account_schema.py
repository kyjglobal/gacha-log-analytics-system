import pytest
from pydantic import ValidationError

from app.schemas.auth import AccountDeleteRequest, AccountUpdateRequest


def test_account_update_trims_nickname() -> None:
    payload = AccountUpdateRequest(nickname="  updated-user  ")

    assert payload.nickname == "updated-user"


def test_account_update_rejects_short_nickname() -> None:
    with pytest.raises(ValidationError):
        AccountUpdateRequest(nickname="a")


def test_account_delete_requires_password_length() -> None:
    with pytest.raises(ValidationError):
        AccountDeleteRequest(password="short")
