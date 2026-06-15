from pydantic import BaseModel


class RankingEntryResponse(BaseModel):
    rank: int
    user_id: int
    nickname: str
    total_draws: int
    mythic_count: int
    mythic_probability: float
    luck_score: float
    is_current_user: bool


class RankingResponse(BaseModel):
    banner_id: int
    banner_name: str
    minimum_draws: int
    entries: list[RankingEntryResponse]
    my_rank: int | None
