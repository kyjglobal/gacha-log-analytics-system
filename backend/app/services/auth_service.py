from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, hash_password, verify_password
from app.models.user import User, Wallet
from app.schemas.auth import LoginRequest, SignUpRequest, TokenResponse


class AuthService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def sign_up(self, payload: SignUpRequest) -> TokenResponse:
        existing_user = await self.session.scalar(
            select(User).where(
                or_(
                    User.email == payload.email,
                    User.nickname == payload.nickname,
                )
            )
        )
        if existing_user is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 사용 중인 이메일 또는 닉네임입니다.",
            )

        user = User(
            email=payload.email,
            nickname=payload.nickname,
            password_hash=hash_password(payload.password),
        )
        self.session.add(user)
        try:
            await self.session.flush()
            self.session.add(Wallet(user_id=user.id, balance=0))
            await self.session.commit()
        except IntegrityError:
            await self.session.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 사용 중인 이메일 또는 닉네임입니다.",
            ) from None
        await self.session.refresh(user)

        return TokenResponse(
            access_token=create_access_token(user.id),
            user=user,
        )

    async def login(self, payload: LoginRequest) -> TokenResponse:
        user = await self.session.scalar(
            select(User).where(
                User.email == payload.email.strip().lower(),
                User.is_deleted.is_(False),
            )
        )
        if user is None or not verify_password(payload.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="이메일 또는 비밀번호가 올바르지 않습니다.",
            )
        if user.status != "active":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="사용할 수 없는 계정입니다.",
            )

        return TokenResponse(
            access_token=create_access_token(user.id),
            user=user,
        )
