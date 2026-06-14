from sqlalchemy import BigInteger, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin


class Inventory(TimestampMixin, Base):
    __tablename__ = "inventories"
    __table_args__ = (
        UniqueConstraint("user_id", "item_id", name="uq_inventory_user_item"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("items.id"),
        index=True,
    )
    quantity: Mapped[int] = mapped_column(Integer, default=0)


class InventoryTransaction(TimestampMixin, Base):
    __tablename__ = "inventory_transactions"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.id"),
        index=True,
    )
    item_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("items.id"),
        index=True,
    )
    transaction_type: Mapped[str] = mapped_column(String(30), index=True)
    quantity_delta: Mapped[int] = mapped_column(Integer)
    quantity_after: Mapped[int] = mapped_column(Integer)
    reference_type: Mapped[str] = mapped_column(String(30))
    reference_id: Mapped[int] = mapped_column(BigInteger)
