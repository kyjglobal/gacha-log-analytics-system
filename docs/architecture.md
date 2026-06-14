# 아키텍처

## 구성 요소

- `frontend`: Flutter Web/App
- `backend`: FastAPI REST API
- `mysql`: InnoDB 영속 저장소
- `alembic`: SQLAlchemy 스키마 마이그레이션

## Frontend

```text
presentation
  -> Riverpod AsyncNotifier / FutureProvider
  -> domain repository interface
  -> data repository implementation
  -> Dio API service
  -> FastAPI
```

커뮤니티 구조:

```text
features/community/
├── data/
│   ├── community_api_service.dart
│   └── community_repository_impl.dart
├── domain/
│   ├── community_category.dart
│   ├── community_comment.dart
│   ├── community_post.dart
│   └── community_repository.dart
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

- `GoRouter`: 홈, 인증, 커뮤니티 목록, 상세, 작성, 수정 경로 관리
- `Riverpod`: 인증 세션, 게시글 목록, 상세, 댓글 상태 관리
- `Dio`: REST API 요청 및 JWT Authorization 헤더 처리
- `flutter_secure_storage`: JWT access token 저장

## Backend

```text
FastAPI endpoint
  -> authentication dependency
  -> service
  -> SQLAlchemy AsyncSession
  -> MySQL
```

- Endpoint는 HTTP 입력과 응답을 담당합니다.
- Schema는 Pydantic 요청/응답 계약을 정의합니다.
- Service는 권한 검사, Soft Delete, 좋아요 토글, transaction을 담당합니다.
- Model은 영속 데이터 구조와 제약조건을 정의합니다.

## 인증 흐름

1. 사용자가 회원가입 또는 로그인을 요청합니다.
2. 비밀번호는 Argon2 기반 해시로 검증합니다.
3. FastAPI가 사용자 ID를 `sub`에 저장한 JWT를 발급합니다.
4. Flutter가 token을 secure storage에 저장합니다.
5. Dio interceptor가 API 요청에 Bearer token을 첨부합니다.
6. FastAPI dependency가 활성 사용자를 조회합니다.

## 커뮤니티 무결성

- 게시글과 댓글 삭제는 `is_deleted`를 사용하는 Soft Delete입니다.
- 작성자 또는 관리자만 수정 및 삭제할 수 있습니다.
- 좋아요는 `(post_id, user_id)` unique constraint로 중복을 차단합니다.
- 좋아요 변경 시 게시글 행을 잠가 `like_count` 동시성 오류를 줄입니다.
- 게시글 목록은 삭제된 게시글과 댓글을 제외합니다.

## 배포 시작 순서

Docker backend는 다음 순서로 실행됩니다.

```text
MySQL health check
  -> alembic upgrade head
  -> uvicorn
```
