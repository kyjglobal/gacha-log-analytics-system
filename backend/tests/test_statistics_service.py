from decimal import Decimal

from app.services.statistics_service import StatisticsService


def test_rate_returns_zero_without_samples() -> None:
    assert StatisticsService._rate(0, 0) == 0.0


def test_rate_returns_observed_probability() -> None:
    assert StatisticsService._rate(3, 10) == 0.3


def test_luck_score_is_zero_without_personal_draws() -> None:
    official = {
        "mythic": Decimal("0.012"),
        "common": Decimal("0.988"),
    }

    assert StatisticsService._luck_score(official, {}) == 0.0


def test_luck_score_increases_for_better_than_expected_results() -> None:
    official = {
        "mythic": Decimal("0.012"),
        "common": Decimal("0.988"),
    }
    personal = {"mythic": 1, "common": 9}

    assert StatisticsService._luck_score(official, personal) > 100
