from fastapi import APIRouter, Response, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.auth import (
    AccountDeleteRequest,
    AccountUpdateRequest,
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


@router.patch("/me", response_model=UserResponse)
async def update_me(
    payload: AccountUpdateRequest,
    session: DbSession,
    current_user: CurrentUser,
) -> UserResponse:
    return await AuthService(session).update_account(payload, current_user)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_me(
    payload: AccountDeleteRequest,
    session: DbSession,
    current_user: CurrentUser,
) -> Response:
    await AuthService(session).delete_account(payload, current_user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
