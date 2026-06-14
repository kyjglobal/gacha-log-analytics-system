from datetime import UTC, datetime
from math import ceil

from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.community import CommunityComment, CommunityLike, CommunityPost
from app.models.user import User
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
)


class CommunityService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list_posts(
        self,
        *,
        page: int,
        size: int,
        category: CommunityCategory | None,
        search: str | None,
    ) -> CommunityPostListResponse:
        filters = [CommunityPost.is_deleted.is_(False)]
        if category is not None:
            filters.append(CommunityPost.category == category.value)
        if search:
            keyword = f"%{search.strip()}%"
            filters.append(
                or_(
                    CommunityPost.title.ilike(keyword),
                    CommunityPost.content.ilike(keyword),
                )
            )

        total = (
            await self.session.scalar(
                select(func.count(CommunityPost.id)).where(*filters)
            )
            or 0
        )
        comment_count = (
            select(func.count(CommunityComment.id))
            .where(
                CommunityComment.post_id == CommunityPost.id,
                CommunityComment.is_deleted.is_(False),
            )
            .correlate(CommunityPost)
            .scalar_subquery()
        )
        rows = (
            await self.session.execute(
                select(CommunityPost, User.nickname, comment_count)
                .join(User, User.id == CommunityPost.user_id)
                .where(*filters)
                .order_by(CommunityPost.created_at.desc())
                .offset((page - 1) * size)
                .limit(size)
            )
        ).all()

        return CommunityPostListResponse(
            items=[
                self._post_response(post, nickname, comments)
                for post, nickname, comments in rows
            ],
            page=page,
            size=size,
            total=total,
            pages=ceil(total / size) if total else 0,
        )

    async def get_post(self, post_id: int) -> CommunityPostResponse:
        post = await self._get_active_post(post_id, for_update=True)
        post.view_count += 1
        await self.session.commit()
        return await self._load_post_response(post_id)

    async def create_post(
        self,
        payload: CommunityPostCreate,
        current_user: User,
    ) -> CommunityPostResponse:
        post = CommunityPost(
            user_id=current_user.id,
            title=payload.title.strip(),
            content=payload.content.strip(),
            category=payload.category.value,
            image_url=payload.image_url,
        )
        self.session.add(post)
        await self.session.commit()
        await self.session.refresh(post)
        return await self._load_post_response(post.id)

    async def update_post(
        self,
        post_id: int,
        payload: CommunityPostUpdate,
        current_user: User,
    ) -> CommunityPostResponse:
        post = await self._get_active_post(post_id)
        self._require_owner(post.user_id, current_user)
        post.title = payload.title.strip()
        post.content = payload.content.strip()
        post.category = payload.category.value
        post.image_url = payload.image_url
        await self.session.commit()
        await self.session.refresh(post)
        return await self._load_post_response(post.id)

    async def delete_post(self, post_id: int, current_user: User) -> None:
        post = await self._get_active_post(post_id)
        self._require_owner(post.user_id, current_user)
        post.is_deleted = True
        post.deleted_at = datetime.now(UTC)
        await self.session.commit()

    async def toggle_like(self, post_id: int, current_user: User) -> LikeResponse:
        post = await self._get_active_post(post_id, for_update=True)
        existing_like = await self.session.scalar(
            select(CommunityLike).where(
                CommunityLike.post_id == post_id,
                CommunityLike.user_id == current_user.id,
            )
        )
        if existing_like is None:
            self.session.add(
                CommunityLike(post_id=post_id, user_id=current_user.id)
            )
            post.like_count += 1
            liked = True
        else:
            await self.session.delete(existing_like)
            post.like_count = max(0, post.like_count - 1)
            liked = False
        await self.session.commit()
        return LikeResponse(liked=liked, like_count=post.like_count)

    async def list_comments(
        self,
        post_id: int,
    ) -> list[CommunityCommentResponse]:
        await self._get_active_post(post_id)
        rows = (
            await self.session.execute(
                select(CommunityComment, User.nickname)
                .join(User, User.id == CommunityComment.user_id)
                .where(
                    CommunityComment.post_id == post_id,
                    CommunityComment.is_deleted.is_(False),
                )
                .order_by(CommunityComment.created_at.asc())
            )
        ).all()
        return [
            self._comment_response(comment, nickname)
            for comment, nickname in rows
        ]

    async def create_comment(
        self,
        post_id: int,
        payload: CommunityCommentCreate,
        current_user: User,
    ) -> CommunityCommentResponse:
        await self._get_active_post(post_id)
        comment = CommunityComment(
            post_id=post_id,
            user_id=current_user.id,
            content=payload.content.strip(),
        )
        self.session.add(comment)
        await self.session.commit()
        await self.session.refresh(comment)
        return self._comment_response(comment, current_user.nickname)

    async def update_comment(
        self,
        comment_id: int,
        payload: CommunityCommentUpdate,
        current_user: User,
    ) -> CommunityCommentResponse:
        comment = await self._get_active_comment(comment_id)
        self._require_owner(comment.user_id, current_user)
        comment.content = payload.content.strip()
        await self.session.commit()
        await self.session.refresh(comment)
        return self._comment_response(comment, current_user.nickname)

    async def delete_comment(self, comment_id: int, current_user: User) -> None:
        comment = await self._get_active_comment(comment_id)
        self._require_owner(comment.user_id, current_user)
        comment.is_deleted = True
        comment.deleted_at = datetime.now(UTC)
        await self.session.commit()

    async def _get_active_post(
        self,
        post_id: int,
        *,
        for_update: bool = False,
    ) -> CommunityPost:
        statement = select(CommunityPost).where(
            CommunityPost.id == post_id,
            CommunityPost.is_deleted.is_(False),
        )
        if for_update:
            statement = statement.with_for_update()
        post = await self.session.scalar(statement)
        if post is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="게시글을 찾을 수 없습니다.",
            )
        return post

    async def _get_active_comment(self, comment_id: int) -> CommunityComment:
        comment = await self.session.scalar(
            select(CommunityComment).where(
                CommunityComment.id == comment_id,
                CommunityComment.is_deleted.is_(False),
            )
        )
        if comment is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="댓글을 찾을 수 없습니다.",
            )
        return comment

    async def _load_post_response(self, post_id: int) -> CommunityPostResponse:
        comment_count = (
            select(func.count(CommunityComment.id))
            .where(
                CommunityComment.post_id == CommunityPost.id,
                CommunityComment.is_deleted.is_(False),
            )
            .correlate(CommunityPost)
            .scalar_subquery()
        )
        row = (
            await self.session.execute(
                select(CommunityPost, User.nickname, comment_count)
                .join(User, User.id == CommunityPost.user_id)
                .where(CommunityPost.id == post_id)
            )
        ).one()
        return self._post_response(row[0], row[1], row[2])

    @staticmethod
    def _require_owner(owner_id: int, current_user: User) -> None:
        if owner_id != current_user.id and current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="수정 또는 삭제 권한이 없습니다.",
            )

    @staticmethod
    def _post_response(
        post: CommunityPost,
        nickname: str,
        comment_count: int,
    ) -> CommunityPostResponse:
        return CommunityPostResponse(
            id=post.id,
            user_id=post.user_id,
            author_nickname=nickname,
            title=post.title,
            content=post.content,
            category=CommunityCategory(post.category),
            image_url=post.image_url,
            like_count=post.like_count,
            view_count=post.view_count,
            comment_count=comment_count,
            created_at=post.created_at,
            updated_at=post.updated_at,
        )

    @staticmethod
    def _comment_response(
        comment: CommunityComment,
        nickname: str,
    ) -> CommunityCommentResponse:
        return CommunityCommentResponse(
            id=comment.id,
            post_id=comment.post_id,
            user_id=comment.user_id,
            author_nickname=nickname,
            content=comment.content,
            created_at=comment.created_at,
        )
