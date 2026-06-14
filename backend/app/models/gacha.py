from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin


class GachaBanner(TimestampMixin, Base):
    __tablename__ = "gacha_banners"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100))
    cost_per_draw: Mapped[int] = mapped_column(BigInteger)
    pity_threshold: Mapped[int] = mapped_column(Integer, default=80)
    starts_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    ends_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True)


class GachaPoolItem(TimestampMixin, Base):
    __tablename__ = "gacha_pool_items"
    __table_args__ = (
        UniqueConstraint("banner_id", "item_id", name="uq_pool_banner_item"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    banner_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("gacha_banners.id"),
        index=True,
    )
    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("items.id"),
        index=True,
    )
    base_probability: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    pickup_weight: Mapped[Decimal] = mapped_column(
        Numeric(10, 8),
        default=Decimal("1"),
    )


class GachaSession(TimestampMixin, Base):
    __tablename__ = "gacha_sessions"

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
    idempotency_key: Mapped[str] = mapped_column(String(64), unique=True)
    draw_count: Mapped[int] = mapped_column(Integer)
    total_cost: Mapped[int] = mapped_column(BigInteger)
    pity_before: Mapped[int] = mapped_column(Integer)
    pity_after: Mapped[int] = mapped_column(Integer)
    status: Mapped[str] = mapped_column(String(20), default="completed", index=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False, index=True)


class GachaResult(TimestampMixin, Base):
    __tablename__ = "gacha_results"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    session_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("gacha_sessions.id"),
        index=True,
    )
    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("items.id"),
        index=True,
    )
    sequence: Mapped[int] = mapped_column(Integer)
    base_probability: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    applied_probability: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    random_value: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    was_pity_applied: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
