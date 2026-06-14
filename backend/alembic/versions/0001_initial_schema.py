"""create initial application schema

Revision ID: 0001_initial_schema
Revises:
Create Date: 2026-06-15
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0001_initial_schema"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def timestamp_columns() -> list[sa.Column]:
    return [
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
    ]


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("nickname", sa.String(length=50), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("is_deleted", sa.Boolean(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        *timestamp_columns(),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
        sa.UniqueConstraint("nickname"),
    )
    op.create_index("ix_users_email", "users", ["email"])
    op.create_index("ix_users_nickname", "users", ["nickname"])
    op.create_index("ix_users_role", "users", ["role"])
    op.create_index("ix_users_status", "users", ["status"])
    op.create_index("ix_users_is_deleted", "users", ["is_deleted"])

    op.create_table(
        "items",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("code", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("rarity", sa.String(length=20), nullable=False),
        sa.Column("description", sa.String(length=500), nullable=True),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        *timestamp_columns(),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code"),
    )
    op.create_index("ix_items_code", "items", ["code"])
    op.create_index("ix_items_name", "items", ["name"])
    op.create_index("ix_items_rarity", "items", ["rarity"])
    op.create_index("ix_items_is_active", "items", ["is_active"])

    op.create_table(
        "gacha_banners",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("cost_per_draw", sa.BigInteger(), nullable=False),
        sa.Column("pity_threshold", sa.Integer(), nullable=False),
        sa.Column("starts_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ends_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        *timestamp_columns(),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_gacha_banners_starts_at", "gacha_banners", ["starts_at"])
    op.create_index("ix_gacha_banners_ends_at", "gacha_banners", ["ends_at"])
    op.create_index("ix_gacha_banners_is_active", "gacha_banners", ["is_active"])

    op.create_table(
        "wallets",
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("balance", sa.BigInteger(), nullable=False),
        sa.Column("version", sa.BigInteger(), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("user_id"),
    )
    op.create_table(
        "wallet_transactions",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("transaction_type", sa.String(length=30), nullable=False),
        sa.Column("amount", sa.BigInteger(), nullable=False),
        sa.Column("balance_after", sa.BigInteger(), nullable=False),
        sa.Column("reference_type", sa.String(length=30), nullable=True),
        sa.Column("reference_id", sa.BigInteger(), nullable=True),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_wallet_transactions_user_id",
        "wallet_transactions",
        ["user_id"],
    )
    op.create_index(
        "ix_wallet_transactions_transaction_type",
        "wallet_transactions",
        ["transaction_type"],
    )

    op.create_table(
        "gacha_pool_items",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("banner_id", sa.BigInteger(), nullable=False),
        sa.Column("item_id", sa.BigInteger(), nullable=False),
        sa.Column("base_probability", sa.Numeric(10, 8), nullable=False),
        sa.Column("pickup_weight", sa.Numeric(10, 8), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["banner_id"], ["gacha_banners.id"]),
        sa.ForeignKeyConstraint(["item_id"], ["items.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "banner_id",
            "item_id",
            name="uq_pool_banner_item",
        ),
    )
    op.create_index("ix_gacha_pool_items_banner_id", "gacha_pool_items", ["banner_id"])
    op.create_index("ix_gacha_pool_items_item_id", "gacha_pool_items", ["item_id"])

    op.create_table(
        "gacha_sessions",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("banner_id", sa.BigInteger(), nullable=False),
        sa.Column("idempotency_key", sa.String(length=64), nullable=False),
        sa.Column("draw_count", sa.Integer(), nullable=False),
        sa.Column("total_cost", sa.BigInteger(), nullable=False),
        sa.Column("pity_before", sa.Integer(), nullable=False),
        sa.Column("pity_after", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("is_deleted", sa.Boolean(), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["banner_id"], ["gacha_banners.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("idempotency_key"),
    )
    op.create_index("ix_gacha_sessions_user_id", "gacha_sessions", ["user_id"])
    op.create_index("ix_gacha_sessions_banner_id", "gacha_sessions", ["banner_id"])
    op.create_index("ix_gacha_sessions_status", "gacha_sessions", ["status"])
    op.create_index("ix_gacha_sessions_is_deleted", "gacha_sessions", ["is_deleted"])

    op.create_table(
        "gacha_results",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("session_id", sa.BigInteger(), nullable=False),
        sa.Column("item_id", sa.BigInteger(), nullable=False),
        sa.Column("sequence", sa.Integer(), nullable=False),
        sa.Column("base_probability", sa.Numeric(10, 8), nullable=False),
        sa.Column("applied_probability", sa.Numeric(10, 8), nullable=False),
        sa.Column("random_value", sa.Numeric(10, 8), nullable=False),
        sa.Column("was_pity_applied", sa.Boolean(), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["item_id"], ["items.id"]),
        sa.ForeignKeyConstraint(["session_id"], ["gacha_sessions.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_gacha_results_session_id", "gacha_results", ["session_id"])
    op.create_index("ix_gacha_results_item_id", "gacha_results", ["item_id"])
    op.create_index(
        "ix_gacha_results_was_pity_applied",
        "gacha_results",
        ["was_pity_applied"],
    )

    op.create_table(
        "user_pity_states",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("banner_id", sa.BigInteger(), nullable=False),
        sa.Column("draw_count", sa.BigInteger(), nullable=False),
        sa.Column("correction_rate", sa.Numeric(10, 8), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["banner_id"], ["gacha_banners.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "user_id",
            "banner_id",
            name="uq_pity_user_banner",
        ),
    )
    op.create_index("ix_user_pity_states_user_id", "user_pity_states", ["user_id"])
    op.create_index(
        "ix_user_pity_states_banner_id",
        "user_pity_states",
        ["banner_id"],
    )

    op.create_table(
        "inventories",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("item_id", sa.BigInteger(), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["item_id"], ["items.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "user_id",
            "item_id",
            name="uq_inventory_user_item",
        ),
    )
    op.create_index("ix_inventories_user_id", "inventories", ["user_id"])
    op.create_index("ix_inventories_item_id", "inventories", ["item_id"])

    op.create_table(
        "inventory_transactions",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("item_id", sa.BigInteger(), nullable=False),
        sa.Column("transaction_type", sa.String(length=30), nullable=False),
        sa.Column("quantity_delta", sa.Integer(), nullable=False),
        sa.Column("quantity_after", sa.Integer(), nullable=False),
        sa.Column("reference_type", sa.String(length=30), nullable=False),
        sa.Column("reference_id", sa.BigInteger(), nullable=False),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["item_id"], ["items.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_inventory_transactions_user_id",
        "inventory_transactions",
        ["user_id"],
    )
    op.create_index(
        "ix_inventory_transactions_item_id",
        "inventory_transactions",
        ["item_id"],
    )
    op.create_index(
        "ix_inventory_transactions_transaction_type",
        "inventory_transactions",
        ["transaction_type"],
    )

    op.create_table(
        "community_posts",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("category", sa.String(length=30), nullable=False),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("like_count", sa.Integer(), nullable=False),
        sa.Column("view_count", sa.Integer(), nullable=False),
        sa.Column("is_deleted", sa.Boolean(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        *timestamp_columns(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_community_posts_user_id", "community_posts", ["user_id"])
    op.create_index("ix_community_posts_category", "community_posts", ["category"])
    op.create_index("ix_community_posts_is_deleted", "community_posts", ["is_deleted"])
    op.create_index(
        "ix_community_posts_category_created",
        "community_posts",
        ["category", "created_at"],
    )
    op.create_index(
        "ix_community_posts_user_created",
        "community_posts",
        ["user_id", "created_at"],
    )

    op.create_table(
        "community_comments",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("post_id", sa.BigInteger(), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column("is_deleted", sa.Boolean(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["post_id"], ["community_posts.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_community_comments_post_id",
        "community_comments",
        ["post_id"],
    )
    op.create_index(
        "ix_community_comments_user_id",
        "community_comments",
        ["user_id"],
    )
    op.create_index(
        "ix_community_comments_is_deleted",
        "community_comments",
        ["is_deleted"],
    )
    op.create_index(
        "ix_community_comments_post_created",
        "community_comments",
        ["post_id", "created_at"],
    )

    op.create_table(
        "community_likes",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("post_id", sa.BigInteger(), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["post_id"], ["community_posts.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "post_id",
            "user_id",
            name="uq_community_like_post_user",
        ),
    )
    op.create_index("ix_community_likes_post_id", "community_likes", ["post_id"])
    op.create_index("ix_community_likes_user_id", "community_likes", ["user_id"])


def downgrade() -> None:
    op.drop_table("community_likes")
    op.drop_table("community_comments")
    op.drop_table("community_posts")
    op.drop_table("inventory_transactions")
    op.drop_table("inventories")
    op.drop_table("user_pity_states")
    op.drop_table("gacha_results")
    op.drop_table("gacha_sessions")
    op.drop_table("gacha_pool_items")
    op.drop_table("wallet_transactions")
    op.drop_table("wallets")
    op.drop_table("gacha_banners")
    op.drop_table("items")
    op.drop_table("users")
