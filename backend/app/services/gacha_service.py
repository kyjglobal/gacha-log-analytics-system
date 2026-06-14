from sqlalchemy.ext.asyncio import AsyncSession


class GachaService:
    """Coordinates the wallet, draw log, inventory, and pity transaction."""

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def draw(self, *, user_id: int, banner_id: int, count: int) -> None:
        raise NotImplementedError(
            "Implement after probability and banner policies are finalized."
        )
