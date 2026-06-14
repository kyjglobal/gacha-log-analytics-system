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

통계 기능은 다음 구조를 사용합니다.

```text
features/statistics/
├── data/
├── domain/
├── presentation/
└── statistics_page.dart
```

`probabilityStatisticsProvider`가 공식·개인·전체 사용자 확률을 한 번에 조회하며, 화면은 서버가 계산한 편차와 Luck Score를 표시합니다.

랭킹 기능도 동일한 계층 구조를 사용합니다.

```text
features/ranking/
├── data/
├── domain/
├── presentation/
└── ranking_page.dart
```

`rankingBoardProvider`는 최소 표본 기준을 충족한 사용자 목록과 현재 사용자의 순위를 조회합니다.

확률 인증 화면은 가챠 이력의 결과 ID만 전달합니다. 아이템명과 확률은 서버가 원본 로그에서 검증하며 클라이언트 입력을 신뢰하지 않습니다.

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

확률 통계는 별도 집계 테이블을 두지 않고 원본 로그를 조회합니다.

```text
gacha_pool_items + items
  -> 등급별 공식 확률

gacha_results + gacha_sessions + items
  -> 개인/전체 사용자 등급별 획득 수와 실제 확률
```

Luck Score는 등급별 가중치(`mythic=100`, `legendary=20`, `epic=5`, `rare=2`, `common=1`)를 적용한 개인 관측값을 공식 기대값으로 나눈 백분율입니다. 표본이 없으면 0을 반환합니다.

랭킹은 사용자별 등급 획득 수를 집계한 뒤 동일한 Luck Score 산식을 적용합니다. 기본 10회 이상의 표본만 포함하며, 동점은 총 추첨 수와 사용자 ID 순서로 결정해 안정적인 정렬을 보장합니다.

확률 인증 생성 흐름:

```text
gacha_result_id
  -> 결과 소유권과 완료 세션 검증
  -> 누적 개인 확률 계산
  -> community_posts 생성
  -> probability_certifications 스냅샷 생성
  -> 단일 트랜잭션 커밋
```

`gacha_result_id`와 `post_id`는 각각 unique constraint를 사용해 중복 인증을 차단합니다.

관리자 API는 `CurrentAdmin` dependency를 사용해 일반 사용자 요청을 403으로 차단합니다.

```text
관리자 JWT
  -> 활성 사용자 검증
  -> role=admin 검증
  -> AdminService
  -> 사용자 상태 / 인벤토리 / 가챠 로그 변경
```

- 정지·차단 사용자는 기존 JWT가 있어도 일반 인증 dependency에서 거부됩니다.
- 가챠 로그 삭제는 `is_deleted`만 변경해 원본 감사 데이터를 유지합니다.
- 아이템 지급·회수는 인벤토리 행을 잠그고 `inventory_transactions`에 관리자 ID를 기록합니다.
- 관리자 본인 계정의 정지·차단은 방지합니다.

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
