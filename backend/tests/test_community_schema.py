import pytest
from pydantic import ValidationError

from app.schemas.community import CommunityPostCreate


def test_community_post_accepts_supported_category() -> None:
    payload = CommunityPostCreate(
        title="신화 획득 결과",
        content="80회 이전에 신화 아이템을 획득했습니다.",
        category="확률 인증",
    )

    assert payload.category.value == "확률 인증"


def test_community_post_rejects_unknown_category() -> None:
    with pytest.raises(ValidationError):
        CommunityPostCreate(
            title="잘못된 카테고리",
            content="지원하지 않는 카테고리입니다.",
            category="거래 게시판",
        )


def test_community_post_rejects_blank_content() -> None:
    with pytest.raises(ValidationError):
        CommunityPostCreate(
            title="공백 내용",
            content="   ",
            category="자유 게시판",
        )
