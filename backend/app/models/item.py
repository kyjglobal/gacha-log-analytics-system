from sqlalchemy import BigInteger, Boolean, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin


class Item(TimestampMixin, Base):
    __tablename__ = "items"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100), index=True)
    rarity: Mapped[str] = mapped_column(String(20), index=True)
    description: Mapped[str | None] = mapped_column(String(500))
    image_url: Mapped[str | None] = mapped_column(String(500))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
