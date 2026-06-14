from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
    Numeric,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin


class CommunityPost(TimestampMixin, Base):
    __tablename__ = "community_posts"
    __table_args__ = (
        Index("ix_community_posts_category_created", "category", "created_at"),
        Index("ix_community_posts_user_created", "user_id", "created_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    title: Mapped[str] = mapped_column(String(200))
    content: Mapped[str] = mapped_column(Text)
    category: Mapped[str] = mapped_column(String(30), index=True)
    image_url: Mapped[str | None] = mapped_column(String(500))
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    view_count: Mapped[int] = mapped_column(Integer, default=0)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class CommunityComment(Base):
    __tablename__ = "community_comments"
    __table_args__ = (
        Index("ix_community_comments_post_created", "post_id", "created_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    post_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("community_posts.id"),
        index=True,
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    content: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class CommunityLike(Base):
    __tablename__ = "community_likes"
    __table_args__ = (
        UniqueConstraint("post_id", "user_id", name="uq_community_like_post_user"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    post_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("community_posts.id"),
        index=True,
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )


class ProbabilityCertification(TimestampMixin, Base):
    __tablename__ = "probability_certifications"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    post_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("community_posts.id"),
        unique=True,
        index=True,
    )
    gacha_result_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("gacha_results.id"),
        unique=True,
        index=True,
    )
    gacha_session_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("gacha_sessions.id"),
        index=True,
    )
    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("items.id"),
        index=True,
    )
    item_name: Mapped[str] = mapped_column(String(100))
    item_rarity: Mapped[str] = mapped_column(String(20))
    draw_count: Mapped[int] = mapped_column(Integer)
    official_probability: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    personal_probability: Mapped[Decimal] = mapped_column(Numeric(10, 8))
    obtained_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
