"""seed connected demo activity

Revision ID: 0004_seed_demo_activity
Revises: 0003_probability_certifications
Create Date: 2026-06-15
"""

from collections import Counter
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Any, Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0004_seed_demo_activity"
down_revision: Union[str, None] = "0003_probability_certifications"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

DEMO_PASSWORD_HASH = (
    "$argon2id$v=19$m=65536,t=3,p=4$HWLnQYKwdgsnHyBYflKu2Q"
    "$00lFWmbLQtpS+yr0hSuRiWVgScLSjtOSRosLiXCq4oE"
)
DEMO_EMAILS = (
    "demo@gacha.local",
    "lucky@gacha.local",
    "analyst@gacha.local",
    "collector@gacha.local",
    "casual@gacha.local",
    "admin@gacha.local",
)
BASE_TIME = datetime(2026, 6, 15, 18, 0, 0)


def _table(name: str, *columns: tuple[str, Any]) -> Any:
    return sa.table(
        name,
        *(sa.column(column_name, column_type) for column_name, column_type in columns),
    )


def _insert_id(
    connection: sa.Connection,
    table: Any,
    values: dict[str, object],
) -> int:
    result = connection.execute(table.insert().values(**values))
    if result.lastrowid is None:
        raise RuntimeError(f"{table.name} 삽입 ID를 확인할 수 없습니다.")
    return int(result.lastrowid)


def _build_rarity_sequence(rarity_counts: dict[str, int]) -> list[str]:
    total = sum(rarity_counts.values())
    slots: list[str | None] = [None] * total
    for rarity in ("mythic", "legendary", "epic", "rare"):
        count = rarity_counts[rarity]
        for index in range(count):
            position = (index + 1) * total // (count + 1)
            while slots[position] is not None:
                position = (position + 1) % total
            slots[position] = rarity
    common_slots = iter(["common"] * rarity_counts["common"])
    return [next(common_slots) if rarity is None else rarity for rarity in slots]


def upgrade() -> None:
    connection = op.get_bind()
    users = _table(
        "users",
        ("id", sa.BigInteger()),
        ("email", sa.String()),
        ("nickname", sa.String()),
        ("password_hash", sa.String()),
        ("role", sa.String()),
        ("status", sa.String()),
        ("is_deleted", sa.Boolean()),
        ("deleted_at", sa.DateTime()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    wallets = _table(
        "wallets",
        ("user_id", sa.BigInteger()),
        ("balance", sa.BigInteger()),
        ("version", sa.BigInteger()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    wallet_transactions = _table(
        "wallet_transactions",
        ("user_id", sa.BigInteger()),
        ("transaction_type", sa.String()),
        ("amount", sa.BigInteger()),
        ("balance_after", sa.BigInteger()),
        ("reference_type", sa.String()),
        ("reference_id", sa.BigInteger()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    sessions = _table(
        "gacha_sessions",
        ("id", sa.BigInteger()),
        ("user_id", sa.BigInteger()),
        ("banner_id", sa.BigInteger()),
        ("idempotency_key", sa.String()),
        ("draw_count", sa.Integer()),
        ("total_cost", sa.BigInteger()),
        ("pity_before", sa.Integer()),
        ("pity_after", sa.Integer()),
        ("status", sa.String()),
        ("is_deleted", sa.Boolean()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    results = _table(
        "gacha_results",
        ("id", sa.BigInteger()),
        ("session_id", sa.BigInteger()),
        ("item_id", sa.BigInteger()),
        ("sequence", sa.Integer()),
        ("base_probability", sa.Numeric(10, 8)),
        ("applied_probability", sa.Numeric(10, 8)),
        ("random_value", sa.Numeric(10, 8)),
        ("was_pity_applied", sa.Boolean()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    inventories = _table(
        "inventories",
        ("user_id", sa.BigInteger()),
        ("item_id", sa.BigInteger()),
        ("quantity", sa.Integer()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    pity_states = _table(
        "user_pity_states",
        ("user_id", sa.BigInteger()),
        ("banner_id", sa.BigInteger()),
        ("draw_count", sa.BigInteger()),
        ("correction_rate", sa.Numeric(10, 8)),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    posts = _table(
        "community_posts",
        ("id", sa.BigInteger()),
        ("user_id", sa.BigInteger()),
        ("title", sa.String()),
        ("content", sa.Text()),
        ("category", sa.String()),
        ("image_url", sa.String()),
        ("like_count", sa.Integer()),
        ("view_count", sa.Integer()),
        ("is_deleted", sa.Boolean()),
        ("deleted_at", sa.DateTime()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )
    comments = _table(
        "community_comments",
        ("post_id", sa.BigInteger()),
        ("user_id", sa.BigInteger()),
        ("content", sa.Text()),
        ("created_at", sa.DateTime()),
        ("is_deleted", sa.Boolean()),
        ("deleted_at", sa.DateTime()),
    )
    likes = _table(
        "community_likes",
        ("post_id", sa.BigInteger()),
        ("user_id", sa.BigInteger()),
        ("created_at", sa.DateTime()),
    )
    certifications = _table(
        "probability_certifications",
        ("post_id", sa.BigInteger()),
        ("gacha_result_id", sa.BigInteger()),
        ("gacha_session_id", sa.BigInteger()),
        ("item_id", sa.BigInteger()),
        ("item_name", sa.String()),
        ("item_rarity", sa.String()),
        ("draw_count", sa.Integer()),
        ("official_probability", sa.Numeric(10, 8)),
        ("personal_probability", sa.Numeric(10, 8)),
        ("obtained_at", sa.DateTime()),
        ("created_at", sa.DateTime()),
        ("updated_at", sa.DateTime()),
    )

    user_specs = [
        ("demo@gacha.local", "별빛여행자", "user"),
        ("lucky@gacha.local", "행운의손", "user"),
        ("analyst@gacha.local", "확률분석가", "user"),
        ("collector@gacha.local", "도감수집가", "user"),
        ("casual@gacha.local", "퇴근후한뽑", "user"),
        ("admin@gacha.local", "운영관리자", "admin"),
    ]
    user_ids: dict[str, int] = {}
    for index, (email, nickname, role) in enumerate(user_specs):
        created_at = BASE_TIME - timedelta(days=45 - index * 3)
        user_id = _insert_id(
            connection,
            users,
            {
                "email": email,
                "nickname": nickname,
                "password_hash": DEMO_PASSWORD_HASH,
                "role": role,
                "status": "active",
                "is_deleted": False,
                "deleted_at": None,
                "created_at": created_at,
                "updated_at": created_at,
            },
        )
        user_ids[email] = user_id

    draw_specs = {
        "demo@gacha.local": {
            "mythic": 2,
            "legendary": 7,
            "epic": 20,
            "rare": 37,
            "common": 54,
        },
        "lucky@gacha.local": {
            "mythic": 4,
            "legendary": 7,
            "epic": 18,
            "rare": 30,
            "common": 41,
        },
        "analyst@gacha.local": {
            "mythic": 1,
            "legendary": 8,
            "epic": 24,
            "rare": 47,
            "common": 70,
        },
        "collector@gacha.local": {
            "mythic": 2,
            "legendary": 5,
            "epic": 15,
            "rare": 27,
            "common": 41,
        },
        "casual@gacha.local": {
            "mythic": 0,
            "legendary": 3,
            "epic": 9,
            "rare": 18,
            "common": 30,
        },
    }
    item_by_rarity = {
        "mythic": 1,
        "legendary": 2,
        "epic": 3,
        "rare": 4,
        "common": 5,
    }
    probability_by_rarity = {
        "mythic": Decimal("0.01200000"),
        "legendary": Decimal("0.05000000"),
        "epic": Decimal("0.15000000"),
        "rare": Decimal("0.30000000"),
        "common": Decimal("0.48800000"),
    }
    featured_results: dict[str, tuple[int, int, int, datetime]] = {}

    for user_index, (email, rarity_counts) in enumerate(draw_specs.items()):
        user_id = user_ids[email]
        rarity_sequence = _build_rarity_sequence(rarity_counts)
        total_draws = len(rarity_sequence)
        final_balance = 50000 - total_draws * 160
        connection.execute(
            wallets.insert().values(
                user_id=user_id,
                balance=final_balance,
                version=total_draws // 10,
                created_at=BASE_TIME - timedelta(days=30),
                updated_at=BASE_TIME,
            )
        )

        inventory_counts: Counter[int] = Counter()
        pity = 0
        cumulative_rarity: Counter[str] = Counter()
        for session_index in range(total_draws // 10):
            chunk = rarity_sequence[session_index * 10 : (session_index + 1) * 10]
            session_time = (
                BASE_TIME
                - timedelta(days=(total_draws // 10) - session_index)
                + timedelta(minutes=user_index * 11)
            )
            pity_before = pity
            for rarity in chunk:
                pity = 0 if rarity == "mythic" else pity + 1
            session_id = _insert_id(
                connection,
                sessions,
                {
                    "user_id": user_id,
                    "banner_id": 1,
                    "idempotency_key": f"demo-{email.split('@')[0]}-{session_index + 1:03d}",
                    "draw_count": 10,
                    "total_cost": 1600,
                    "pity_before": pity_before,
                    "pity_after": pity,
                    "status": "completed",
                    "is_deleted": False,
                    "created_at": session_time,
                    "updated_at": session_time,
                },
            )
            balance_after = 50000 - (session_index + 1) * 1600
            connection.execute(
                wallet_transactions.insert().values(
                    user_id=user_id,
                    transaction_type="gacha_draw",
                    amount=-1600,
                    balance_after=balance_after,
                    reference_type="gacha_session",
                    reference_id=session_id,
                    created_at=session_time,
                    updated_at=session_time,
                )
            )
            for sequence, rarity in enumerate(chunk, start=1):
                item_id = item_by_rarity[rarity]
                probability = probability_by_rarity[rarity]
                cumulative_rarity[rarity] += 1
                inventory_counts[item_id] += 1
                result_id = _insert_id(
                    connection,
                    results,
                    {
                        "session_id": session_id,
                        "item_id": item_id,
                        "sequence": sequence,
                        "base_probability": probability,
                        "applied_probability": probability,
                        "random_value": Decimal(
                            f"0.{(user_index + 2) * 1000000 + session_index * 1000 + sequence:08d}"
                        ),
                        "was_pity_applied": False,
                        "created_at": session_time + timedelta(seconds=sequence),
                        "updated_at": session_time + timedelta(seconds=sequence),
                    },
                )
                if rarity == "mythic":
                    featured_results[email] = (
                        result_id,
                        session_id,
                        sum(cumulative_rarity.values()),
                        session_time + timedelta(seconds=sequence),
                    )

        for item_id, quantity in inventory_counts.items():
            connection.execute(
                inventories.insert().values(
                    user_id=user_id,
                    item_id=item_id,
                    quantity=quantity,
                    created_at=BASE_TIME - timedelta(days=30),
                    updated_at=BASE_TIME,
                )
            )
        connection.execute(
            pity_states.insert().values(
                user_id=user_id,
                banner_id=1,
                draw_count=pity,
                correction_rate=Decimal("0.00000000"),
                created_at=BASE_TIME - timedelta(days=30),
                updated_at=BASE_TIME,
            )
        )

    connection.execute(
        wallets.insert().values(
            user_id=user_ids["admin@gacha.local"],
            balance=999999,
            version=0,
            created_at=BASE_TIME - timedelta(days=30),
            updated_at=BASE_TIME,
        )
    )

    post_specs = [
        (
            "demo@gacha.local",
            "확률 인증",
            "120회 만에 아스트라 왕관 획득했습니다",
            "천상의 궤적 배너를 꾸준히 기록한 결과입니다. 개인 획득 확률과 공식 확률을 함께 확인해 보세요.",
            42,
        ),
        (
            "lucky@gacha.local",
            "가챠 자랑",
            "오늘 10연차 결과가 믿기지 않네요",
            "전설 이상 아이템이 연속으로 나왔습니다. 이런 날도 있네요. 다음 기록도 바로 남겨보겠습니다.",
            38,
        ),
        (
            "analyst@gacha.local",
            "통계 분석",
            "현재 520회 커뮤니티 표본 분석",
            "표본이 아직 크지는 않지만 신화 등급은 공식 확률 근처로 수렴하고 있습니다. 전설 등급은 소폭 높은 상태입니다.",
            67,
        ),
        (
            "collector@gacha.local",
            "공략 및 팁",
            "천장 전에 재화를 관리하는 방법",
            "10회 소환 단위로 기록하고 현재 천장 횟수와 남은 재화를 함께 확인하면 충동적인 사용을 줄일 수 있습니다.",
            51,
        ),
        (
            "casual@gacha.local",
            "자유 게시판",
            "퇴근 후 한 번씩 기록하는 중입니다",
            "매일 조금씩 모아서 뽑고 있습니다. 아직 신화는 없지만 통계가 쌓이는 과정을 보는 재미가 있네요.",
            29,
        ),
        (
            "collector@gacha.local",
            "가챠 자랑",
            "드디어 도감 다섯 등급을 모두 채웠습니다",
            "신화부터 일반까지 전 등급을 보유하게 되었습니다. 다음 목표는 아스트라 왕관 두 개입니다.",
            45,
        ),
        (
            "analyst@gacha.local",
            "통계 분석",
            "행운 점수는 어떻게 읽으면 좋을까요?",
            "100점은 공식 확률에 가까운 결과를 의미합니다. 표본이 적을 때는 크게 흔들릴 수 있으니 누적 추첨 수도 같이 보세요.",
            73,
        ),
        (
            "demo@gacha.local",
            "공략 및 팁",
            "확률 인증 게시글 작성 방법",
            "가챠 이력에서 인증할 결과를 선택하면 아이템, 등급, 공식 확률과 개인 확률이 자동으로 첨부됩니다.",
            34,
        ),
        (
            "lucky@gacha.local",
            "확률 인증",
            "행운의손 신화 획득 기록 공개",
            "이번 신화 획득 결과를 인증합니다. 표본은 100회이며 앞으로도 결과를 계속 공유하겠습니다.",
            58,
        ),
        (
            "admin@gacha.local",
            "자유 게시판",
            "커뮤니티 이용 안내",
            "타인의 결과를 존중해 주세요. 확률 인증 게시글은 서버에 저장된 실제 가챠 결과만 사용할 수 있습니다.",
            81,
        ),
    ]
    post_ids: list[int] = []
    for index, (email, category, title, content, views) in enumerate(post_specs):
        created_at = BASE_TIME - timedelta(hours=(len(post_specs) - index) * 5)
        post_ids.append(
            _insert_id(
                connection,
                posts,
                {
                    "user_id": user_ids[email],
                    "title": title,
                    "content": content,
                    "category": category,
                    "image_url": None,
                    "like_count": 0,
                    "view_count": views,
                    "is_deleted": False,
                    "deleted_at": None,
                    "created_at": created_at,
                    "updated_at": created_at,
                },
            )
        )

    liker_groups = [
        DEMO_EMAILS[1:6],
        DEMO_EMAILS[0:4],
        DEMO_EMAILS[0:6],
        DEMO_EMAILS[0:5],
        DEMO_EMAILS[0:3],
        DEMO_EMAILS[0:4],
        DEMO_EMAILS[0:6],
        DEMO_EMAILS[1:5],
        DEMO_EMAILS[0:6],
        DEMO_EMAILS[0:5],
    ]
    for post_id, liker_emails in zip(post_ids, liker_groups, strict=True):
        for offset, email in enumerate(liker_emails):
            connection.execute(
                likes.insert().values(
                    post_id=post_id,
                    user_id=user_ids[email],
                    created_at=BASE_TIME - timedelta(hours=offset + 1),
                )
            )
        connection.execute(
            posts.update()
            .where(posts.c.id == post_id)
            .values(like_count=len(liker_emails))
        )

    comment_specs = [
        (0, "analyst@gacha.local", "120회 데이터라서 개인 통계 비교에도 도움이 되겠네요."),
        (0, "collector@gacha.local", "인증 정보가 자동으로 붙는 점이 좋습니다."),
        (1, "demo@gacha.local", "전설 연속 획득 축하드립니다."),
        (2, "lucky@gacha.local", "표본이 더 쌓이면 다시 분석 부탁드립니다."),
        (2, "casual@gacha.local", "숫자로 보니 체감과 차이가 꽤 있네요."),
        (3, "demo@gacha.local", "천장과 재화를 함께 보는 습관을 들여야겠어요."),
        (4, "collector@gacha.local", "꾸준히 기록하면 신화도 곧 나올 겁니다."),
        (6, "demo@gacha.local", "표본 수와 함께 봐야 한다는 설명이 이해하기 쉽네요."),
        (8, "analyst@gacha.local", "100회에 신화 4개면 행운 점수가 높게 나오겠네요."),
        (9, "demo@gacha.local", "확률 인증은 실제 결과만 사용한다는 점 확인했습니다."),
    ]
    for index, (post_index, email, content) in enumerate(comment_specs):
        connection.execute(
            comments.insert().values(
                post_id=post_ids[post_index],
                user_id=user_ids[email],
                content=content,
                created_at=BASE_TIME - timedelta(hours=10 - index),
                is_deleted=False,
                deleted_at=None,
            )
        )

    certification_specs = [
        (0, "demo@gacha.local", 2, 120),
        (8, "lucky@gacha.local", 4, 100),
    ]
    for post_index, email, mythic_count, total_draws in certification_specs:
        result_id, session_id, draw_count, obtained_at = featured_results[email]
        connection.execute(
            certifications.insert().values(
                post_id=post_ids[post_index],
                gacha_result_id=result_id,
                gacha_session_id=session_id,
                item_id=1,
                item_name="Astra Crown",
                item_rarity="mythic",
                draw_count=draw_count,
                official_probability=Decimal("0.01200000"),
                personal_probability=Decimal(mythic_count) / Decimal(total_draws),
                obtained_at=obtained_at,
                created_at=obtained_at,
                updated_at=obtained_at,
            )
        )


def downgrade() -> None:
    connection = op.get_bind()
    email_list = ", ".join(f"'{email}'" for email in DEMO_EMAILS)
    user_ids = f"(SELECT id FROM users WHERE email IN ({email_list}))"
    post_ids = f"(SELECT id FROM community_posts WHERE user_id IN {user_ids})"
    session_ids = (
        "(SELECT id FROM gacha_sessions "
        "WHERE idempotency_key LIKE 'demo-%')"
    )
    connection.execute(
        sa.text(
            "DELETE FROM probability_certifications "
            f"WHERE post_id IN {post_ids} OR gacha_session_id IN {session_ids}"
        )
    )
    connection.execute(sa.text(f"DELETE FROM community_likes WHERE post_id IN {post_ids}"))
    connection.execute(
        sa.text(f"DELETE FROM community_comments WHERE post_id IN {post_ids}")
    )
    connection.execute(
        sa.text(f"DELETE FROM community_posts WHERE user_id IN {user_ids}")
    )
    connection.execute(
        sa.text(f"DELETE FROM inventory_transactions WHERE user_id IN {user_ids}")
    )
    connection.execute(sa.text(f"DELETE FROM inventories WHERE user_id IN {user_ids}"))
    connection.execute(
        sa.text(f"DELETE FROM user_pity_states WHERE user_id IN {user_ids}")
    )
    connection.execute(
        sa.text(f"DELETE FROM gacha_results WHERE session_id IN {session_ids}")
    )
    connection.execute(
        sa.text(
            "DELETE FROM wallet_transactions "
            "WHERE reference_type = 'gacha_session' "
            f"AND reference_id IN {session_ids}"
        )
    )
    connection.execute(
        sa.text("DELETE FROM gacha_sessions WHERE idempotency_key LIKE 'demo-%'")
    )
    connection.execute(sa.text(f"DELETE FROM wallets WHERE user_id IN {user_ids}"))
    connection.execute(sa.text(f"DELETE FROM users WHERE email IN ({email_list})"))
