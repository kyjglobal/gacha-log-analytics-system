import jwt

from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)


def test_password_hash_round_trip() -> None:
    password = "secure-password-123"
    hashed = hash_password(password)

    assert hashed != password
    assert verify_password(password, hashed)
    assert not verify_password("wrong-password", hashed)


def test_access_token_round_trip() -> None:
    token = create_access_token(42)

    assert decode_access_token(token) == 42


def test_invalid_access_token_is_rejected() -> None:
    try:
        decode_access_token("not-a-token")
    except jwt.InvalidTokenError:
        return
    raise AssertionError("invalid token must be rejected")
