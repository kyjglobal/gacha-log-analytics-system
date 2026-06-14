from pydantic import BaseModel


class RarityStatisticResponse(BaseModel):
    rarity: str
    official_probability: float
    personal_count: int
    personal_probability: float
    personal_deviation: float
    community_count: int
    community_probability: float


class ProbabilityStatisticsResponse(BaseModel):
    banner_id: int
    banner_name: str
    personal_total_draws: int
    community_total_draws: int
    luck_score: float
    rarities: list[RarityStatisticResponse]
