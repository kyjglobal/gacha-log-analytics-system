from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, ConfigDict, Field, field_validator


class CommunityCategory(StrEnum):
    probability = "확률 인증"
    showcase = "가챠 자랑"
    analysis = "통계 분석"
    guide = "공략 및 팁"
    free = "자유 게시판"


class CommunityPostCreate(BaseModel):
    title: str = Field(min_length=2, max_length=200)
    content: str = Field(min_length=1, max_length=20000)
    category: CommunityCategory
    image_url: str | None = Field(default=None, max_length=500)

    @field_validator("title", "content")
    @classmethod
    def reject_blank_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("공백만 입력할 수 없습니다.")
        return normalized


class CommunityPostUpdate(BaseModel):
    title: str = Field(min_length=2, max_length=200)
    content: str = Field(min_length=1, max_length=20000)
    category: CommunityCategory
    image_url: str | None = Field(default=None, max_length=500)

    @field_validator("title", "content")
    @classmethod
    def reject_blank_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("공백만 입력할 수 없습니다.")
        return normalized


class ProbabilityCertificationCreate(BaseModel):
    gacha_result_id: int = Field(ge=1)
    title: str = Field(min_length=2, max_length=200)
    content: str = Field(min_length=1, max_length=20000)
    image_url: str | None = Field(default=None, max_length=500)

    @field_validator("title", "content")
    @classmethod
    def reject_blank_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("공백만 입력할 수 없습니다.")
        return normalized


class ProbabilityCertificationResponse(BaseModel):
    id: int
    gacha_result_id: int
    gacha_session_id: int
    item_id: int
    item_name: str
    item_rarity: str
    draw_count: int
    official_probability: float
    personal_probability: float
    obtained_at: datetime


class CommunityPostResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    author_nickname: str
    title: str
    content: str
    category: CommunityCategory
    image_url: str | None
    like_count: int
    view_count: int
    comment_count: int = 0
    certification: ProbabilityCertificationResponse | None = None
    created_at: datetime
    updated_at: datetime


class CommunityPostListResponse(BaseModel):
    items: list[CommunityPostResponse]
    page: int
    size: int
    total: int
    pages: int


class CommunityCommentCreate(BaseModel):
    content: str = Field(min_length=1, max_length=2000)

    @field_validator("content")
    @classmethod
    def reject_blank_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("공백만 입력할 수 없습니다.")
        return normalized


class CommunityCommentUpdate(BaseModel):
    content: str = Field(min_length=1, max_length=2000)

    @field_validator("content")
    @classmethod
    def reject_blank_text(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("공백만 입력할 수 없습니다.")
        return normalized


class CommunityCommentResponse(BaseModel):
    id: int
    post_id: int
    user_id: int
    author_nickname: str
    content: str
    created_at: datetime


class LikeResponse(BaseModel):
    liked: bool
    like_count: int
