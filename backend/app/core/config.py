from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Gacha Log API"
    api_v1_prefix: str = "/api/v1"
    database_url: str = (
        "mysql+asyncmy://gacha:gacha_password@localhost:3306/gacha_log"
    )
    jwt_secret_key: str = "change-this-secret-before-production-32-bytes"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    initial_wallet_balance: int = 12840
    cors_origins: str = "http://localhost:3000,http://localhost:8080"

    model_config = SettingsConfigDict(
        env_file=("../.env", ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
