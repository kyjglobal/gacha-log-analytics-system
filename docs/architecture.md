# 아키텍처

## 구성

- `frontend`: Flutter Web/App, Material 3, Riverpod, Dio, GoRouter
- `backend`: FastAPI, SQLAlchemy AsyncSession, Alembic
- `mysql`: MySQL 8.4 InnoDB
- `docker-compose.yml`: 로컬 MySQL과 API 실행

## Frontend

```text
presentation
  -> Riverpod provider / AsyncNotifier
  -> domain repository interface
  -> data repository implementation
  -> Dio API service
  -> FastAPI
```

가챠 기능은 다음 구조를 사용합니다.

```text
features/gacha/
├── data/
│   ├── gacha_api_service.dart
│   └── gacha_repository_impl.dart
├── domain/
│   ├── gacha_models.dart
│   └── gacha_repository.dart
└── presentation/
    ├── gacha_history_screen.dart
    └── gacha_providers.dart
```

- `gachaBannersProvider`: 배너, 지갑 잔액, 천장 상태 조회
- `gachaDrawProvider`: 추첨 요청과 완료 후 관련 캐시 무효화
- `gachaHistoryProvider`: 사용자 추첨 이력 조회
- `inventoryProvider`: 등급별 인벤토리 조회

클라이언트는 확률 계산이나 재화 차감을 수행하지 않습니다. 서버 응답만 화면 상태에 반영합니다.

## Backend

```text
FastAPI endpoint
  -> JWT authentication dependency
  -> service
  -> SQLAlchemy AsyncSession
  -> MySQL
```

가챠 트랜잭션 처리 순서:

1. 사용자·배너·확률 풀과 `Idempotency-Key`를 검증합니다.
2. 지갑과 천장 상태를 `SELECT ... FOR UPDATE`로 잠급니다.
3. 1회 또는 10회 결과를 순서대로 생성합니다.
4. 재화, 가챠 세션·결과, 인벤토리, 천장, 거래 로그를 갱신합니다.
5. 모든 변경을 한 번에 커밋하며 오류가 발생하면 전체 롤백합니다.

`gacha_sessions.idempotency_key`의 unique constraint로 재시도에 의한 중복 차감을 방지합니다.

## 데이터 무결성

- 사용자와 가챠 로그 삭제는 `is_deleted` 기반 Soft Delete를 사용합니다.
- 인벤토리는 `(user_id, item_id)` unique constraint로 중복 행을 방지합니다.
- 좋아요는 `(post_id, user_id)` unique constraint로 중복을 방지합니다.
- 공식 확률과 실제 적용 확률, 난수값, 천장 적용 여부를 결과별로 저장합니다.
- 모든 테이블은 InnoDB의 FK와 트랜잭션을 사용합니다.

## 실행 순서

Docker backend는 다음 순서로 시작합니다.

```text
MySQL health check
  -> alembic upgrade head
  -> uvicorn
```
