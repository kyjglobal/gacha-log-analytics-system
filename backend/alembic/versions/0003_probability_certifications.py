"""create probability certifications

Revision ID: 0003_probability_certifications
Revises: 0002_seed_gacha_catalog
Create Date: 2026-06-15
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0003_probability_certifications"
down_revision: Union[str, None] = "0002_seed_gacha_catalog"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "probability_certifications",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("post_id", sa.BigInteger(), nullable=False),
        sa.Column("gacha_result_id", sa.BigInteger(), nullable=False),
        sa.Column("gacha_session_id", sa.BigInteger(), nullable=False),
        sa.Column("item_id", sa.BigInteger(), nullable=False),
        sa.Column("item_name", sa.String(length=100), nullable=False),
        sa.Column("item_rarity", sa.String(length=20), nullable=False),
        sa.Column("draw_count", sa.Integer(), nullable=False),
        sa.Column(
            "official_probability",
            sa.Numeric(10, 8),
            nullable=False,
        ),
        sa.Column(
            "personal_probability",
            sa.Numeric(10, 8),
            nullable=False,
        ),
        sa.Column("obtained_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["post_id"], ["community_posts.id"]),
        sa.ForeignKeyConstraint(["gacha_result_id"], ["gacha_results.id"]),
        sa.ForeignKeyConstraint(["gacha_session_id"], ["gacha_sessions.id"]),
        sa.ForeignKeyConstraint(["item_id"], ["items.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("post_id"),
        sa.UniqueConstraint("gacha_result_id"),
    )
    op.create_index(
        "ix_probability_certifications_post_id",
        "probability_certifications",
        ["post_id"],
    )
    op.create_index(
        "ix_probability_certifications_gacha_result_id",
        "probability_certifications",
        ["gacha_result_id"],
    )
    op.create_index(
        "ix_probability_certifications_gacha_session_id",
        "probability_certifications",
        ["gacha_session_id"],
    )
    op.create_index(
        "ix_probability_certifications_item_id",
        "probability_certifications",
        ["item_id"],
    )


def downgrade() -> None:
    op.drop_table("probability_certifications")
