from decimal import Decimal

from app.services.ranking_service import RankingService


def test_build_ranked_entries_orders_by_luck_score() -> None:
    official = {
        "mythic": Decimal("0.012"),
        "common": Decimal("0.988"),
    }
    user_results = {
        1: ("first", {"mythic": 1, "common": 9}),
        2: ("second", {"common": 10}),
    }

    entries = RankingService._build_ranked_entries(
        user_results=user_results,
        official=official,
        current_user_id=2,
        minimum_draws=10,
    )

    assert [entry.user_id for entry in entries] == [1, 2]
    assert entries[1].is_current_user is True


def test_build_ranked_entries_excludes_small_samples() -> None:
    official = {"common": Decimal("1")}
    user_results = {
        1: ("eligible", {"common": 10}),
        2: ("too-small", {"common": 9}),
    }

    entries = RankingService._build_ranked_entries(
        user_results=user_results,
        official=official,
        current_user_id=1,
        minimum_draws=10,
    )

    assert len(entries) == 1
    assert entries[0].nickname == "eligible"


def test_build_ranked_entries_uses_draw_count_as_tiebreaker() -> None:
    official = {"common": Decimal("1")}
    user_results = {
        1: ("ten", {"common": 10}),
        2: ("twenty", {"common": 20}),
    }

    entries = RankingService._build_ranked_entries(
        user_results=user_results,
        official=official,
        current_user_id=1,
        minimum_draws=10,
    )

    assert [entry.user_id for entry in entries] == [2, 1]
