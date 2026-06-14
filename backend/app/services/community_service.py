from datetime import UTC, datetime
from decimal import Decimal
from math import ceil

from fastapi import HTTPException, status
from sqlalchemy import func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.community import (
    CommunityComment,
    CommunityLike,
    CommunityPost,
    ProbabilityCertification,
)
from app.models.gacha import GachaResult, GachaSession
from app.models.item import Item
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
    ProbabilityCertificationCreate,
    ProbabilityCertificationResponse,
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
                select(
                    CommunityPost,
                    User.nickname,
                    comment_count,
                    ProbabilityCertification,
                )
                .join(User, User.id == CommunityPost.user_id)
                .outerjoin(
                    ProbabilityCertification,
                    ProbabilityCertification.post_id == CommunityPost.id,
                )
                .where(*filters)
                .order_by(CommunityPost.created_at.desc())
                .offset((page - 1) * size)
                .limit(size)
            )
        ).all()

        return CommunityPostListResponse(
            items=[
                self._post_response(post, nickname, comments, certification)
                for post, nickname, comments, certification in rows
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
        self._reject_unverified_probability_category(payload.category)
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

    async def create_probability_certification(
        self,
        payload: ProbabilityCertificationCreate,
        current_user: User,
    ) -> CommunityPostResponse:
        result_row = (
            await self.session.execute(
                select(GachaResult, GachaSession, Item)
                .join(
                    GachaSession,
                    GachaSession.id == GachaResult.session_id,
                )
                .join(Item, Item.id == GachaResult.item_id)
                .where(
                    GachaResult.id == payload.gacha_result_id,
                    GachaSession.user_id == current_user.id,
                    GachaSession.status == "completed",
                    GachaSession.is_deleted.is_(False),
                )
            )
        ).one_or_none()
        if result_row is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="인증 가능한 가챠 결과를 찾을 수 없습니다.",
            )
        existing = await self.session.scalar(
            select(ProbabilityCertification.id).where(
                ProbabilityCertification.gacha_result_id
                == payload.gacha_result_id
            )
        )
        if existing is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 인증 게시글로 등록된 가챠 결과입니다.",
            )

        result, gacha_session, item = result_row
        personal_total = (
            await self.session.scalar(
                select(func.count(GachaResult.id))
                .join(
                    GachaSession,
                    GachaSession.id == GachaResult.session_id,
                )
                .where(
                    GachaSession.user_id == current_user.id,
                    GachaSession.banner_id == gacha_session.banner_id,
                    GachaSession.status == "completed",
                    GachaSession.is_deleted.is_(False),
                    GachaSession.id <= gacha_session.id,
                )
            )
            or 0
        )
        personal_rarity_count = (
            await self.session.scalar(
                select(func.count(GachaResult.id))
                .join(
                    GachaSession,
                    GachaSession.id == GachaResult.session_id,
                )
                .join(Item, Item.id == GachaResult.item_id)
                .where(
                    GachaSession.user_id == current_user.id,
                    GachaSession.banner_id == gacha_session.banner_id,
                    GachaSession.status == "completed",
                    GachaSession.is_deleted.is_(False),
                    GachaSession.id <= gacha_session.id,
                    Item.rarity == item.rarity,
                )
            )
            or 0
        )

        post = CommunityPost(
            user_id=current_user.id,
            title=payload.title.strip(),
            content=payload.content.strip(),
            category=CommunityCategory.probability.value,
            image_url=payload.image_url,
        )
        self.session.add(post)
        await self.session.flush()
        self.session.add(
            ProbabilityCertification(
                post_id=post.id,
                gacha_result_id=result.id,
                gacha_session_id=gacha_session.id,
                item_id=item.id,
                item_name=item.name,
                item_rarity=item.rarity,
                draw_count=personal_total,
                official_probability=result.base_probability,
                personal_probability=(
                    Decimal(personal_rarity_count) / Decimal(personal_total)
                    if personal_total
                    else Decimal("0")
                ),
                obtained_at=result.created_at,
            )
        )
        try:
            await self.session.commit()
        except IntegrityError:
            await self.session.rollback()
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 인증 게시글로 등록된 가챠 결과입니다.",
            ) from None
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
        certification_id = await self.session.scalar(
            select(ProbabilityCertification.id).where(
                ProbabilityCertification.post_id == post.id
            )
        )
        if certification_id is None:
            self._reject_unverified_probability_category(payload.category)
        post.category = (
            CommunityCategory.probability.value
            if certification_id is not None
            else payload.category.value
        )
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
                select(
                    CommunityPost,
                    User.nickname,
                    comment_count,
                    ProbabilityCertification,
                )
                .join(User, User.id == CommunityPost.user_id)
                .outerjoin(
                    ProbabilityCertification,
                    ProbabilityCertification.post_id == CommunityPost.id,
                )
                .where(CommunityPost.id == post_id)
            )
        ).one()
        return self._post_response(row[0], row[1], row[2], row[3])

    @staticmethod
    def _require_owner(owner_id: int, current_user: User) -> None:
        if owner_id != current_user.id and current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="수정 또는 삭제 권한이 없습니다.",
            )

    @staticmethod
    def _reject_unverified_probability_category(
        category: CommunityCategory,
    ) -> None:
        if category == CommunityCategory.probability:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="확률 인증 카테고리는 검증된 가챠 결과로만 생성할 수 있습니다.",
            )

    @staticmethod
    def _post_response(
        post: CommunityPost,
        nickname: str,
        comment_count: int,
        certification: ProbabilityCertification | None = None,
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
            certification=(
                ProbabilityCertificationResponse(
                    id=certification.id,
                    gacha_result_id=certification.gacha_result_id,
                    gacha_session_id=certification.gacha_session_id,
                    item_id=certification.item_id,
                    item_name=certification.item_name,
                    item_rarity=certification.item_rarity,
                    draw_count=certification.draw_count,
                    official_probability=float(
                        certification.official_probability
                    ),
                    personal_probability=float(
                        certification.personal_probability
                    ),
                    obtained_at=certification.obtained_at,
                )
                if certification is not None
                else None
            ),
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
