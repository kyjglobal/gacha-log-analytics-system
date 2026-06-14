from typing import Annotated

from fastapi import APIRouter, Query, Response, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.community import (
    CommunityCategory,
    CommunityCommentCreate,
    CommunityCommentResponse,
    CommunityCommentUpdate,
    CommunityPostCreate,
    CommunityPostListResponse,
    CommunityPostResponse,
    CommunityPostUpdate,
    LikeResponse,
    ProbabilityCertificationCreate,
)
from app.services.community_service import CommunityService

router = APIRouter()


@router.get("/posts", response_model=CommunityPostListResponse)
async def list_posts(
    session: DbSession,
    page: Annotated[int, Query(ge=1)] = 1,
    size: Annotated[int, Query(ge=1, le=100)] = 20,
    category: CommunityCategory | None = None,
    search: Annotated[str | None, Query(max_length=100)] = None,
) -> CommunityPostListResponse:
    return await CommunityService(session).list_posts(
        page=page,
        size=size,
        category=category,
        search=search,
    )


@router.get("/posts/{post_id}", response_model=CommunityPostResponse)
async def get_post(post_id: int, session: DbSession) -> CommunityPostResponse:
    return await CommunityService(session).get_post(post_id)


@router.post("/posts", response_model=CommunityPostResponse, status_code=201)
async def create_post(
    payload: CommunityPostCreate,
    session: DbSession,
    current_user: CurrentUser,
) -> CommunityPostResponse:
    return await CommunityService(session).create_post(payload, current_user)


@router.post(
    "/certifications",
    response_model=CommunityPostResponse,
    status_code=201,
)
async def create_probability_certification(
    payload: ProbabilityCertificationCreate,
    session: DbSession,
    current_user: CurrentUser,
) -> CommunityPostResponse:
    return await CommunityService(session).create_probability_certification(
        payload,
        current_user,
    )


@router.put("/posts/{post_id}", response_model=CommunityPostResponse)
async def update_post(
    post_id: int,
    payload: CommunityPostUpdate,
    session: DbSession,
    current_user: CurrentUser,
) -> CommunityPostResponse:
    return await CommunityService(session).update_post(
        post_id,
        payload,
        current_user,
    )


@router.delete("/posts/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_post(
    post_id: int,
    session: DbSession,
    current_user: CurrentUser,
) -> Response:
    await CommunityService(session).delete_post(post_id, current_user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/posts/{post_id}/like", response_model=LikeResponse)
async def toggle_like(
    post_id: int,
    session: DbSession,
    current_user: CurrentUser,
) -> LikeResponse:
    return await CommunityService(session).toggle_like(post_id, current_user)


@router.get(
    "/posts/{post_id}/comments",
    response_model=list[CommunityCommentResponse],
)
async def list_comments(
    post_id: int,
    session: DbSession,
) -> list[CommunityCommentResponse]:
    return await CommunityService(session).list_comments(post_id)


@router.post(
    "/posts/{post_id}/comments",
    response_model=CommunityCommentResponse,
    status_code=201,
)
async def create_comment(
    post_id: int,
    payload: CommunityCommentCreate,
    session: DbSession,
    current_user: CurrentUser,
) -> CommunityCommentResponse:
    return await CommunityService(session).create_comment(
        post_id,
        payload,
        current_user,
    )


@router.put("/comments/{comment_id}", response_model=CommunityCommentResponse)
async def update_comment(
    comment_id: int,
    payload: CommunityCommentUpdate,
    session: DbSession,
    current_user: CurrentUser,
) -> CommunityCommentResponse:
    return await CommunityService(session).update_comment(
        comment_id,
        payload,
        current_user,
    )


@router.delete(
    "/comments/{comment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_comment(
    comment_id: int,
    session: DbSession,
    current_user: CurrentUser,
) -> Response:
    await CommunityService(session).delete_comment(comment_id, current_user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
