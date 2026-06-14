from fastapi import APIRouter

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.auth import (
    LoginRequest,
    SignUpRequest,
    TokenResponse,
    UserResponse,
)
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/signup", response_model=TokenResponse, status_code=201)
async def sign_up(payload: SignUpRequest, session: DbSession) -> TokenResponse:
    return await AuthService(session).sign_up(payload)


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, session: DbSession) -> TokenResponse:
    return await AuthService(session).login(payload)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: CurrentUser) -> UserResponse:
    return UserResponse.model_validate(current_user)
