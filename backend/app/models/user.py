from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Numeric,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin


class User(TimestampMixin, Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    nickname: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(20), default="user", index=True)
    status: Mapped[str] = mapped_column(String(20), default="active", index=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class Wallet(TimestampMixin, Base):
    __tablename__ = "wallets"

    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        primary_key=True,
    )
    balance: Mapped[int] = mapped_column(BigInteger, default=0)
    version: Mapped[int] = mapped_column(BigInteger, default=0)


class WalletTransaction(TimestampMixin, Base):
    __tablename__ = "wallet_transactions"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    transaction_type: Mapped[str] = mapped_column(String(30), index=True)
    amount: Mapped[int] = mapped_column(BigInteger)
    balance_after: Mapped[int] = mapped_column(BigInteger)
    reference_type: Mapped[str | None] = mapped_column(String(30))
    reference_id: Mapped[int | None] = mapped_column(BigInteger)


class UserPityState(TimestampMixin, Base):
    __tablename__ = "user_pity_states"
    __table_args__ = (
        UniqueConstraint("user_id", "banner_id", name="uq_pity_user_banner"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    banner_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("gacha_banners.id"),
        index=True,
    )
    draw_count: Mapped[int] = mapped_column(BigInteger, default=0)
    correction_rate: Mapped[Decimal] = mapped_column(
        Numeric(10, 8),
        default=Decimal("0"),
    )
