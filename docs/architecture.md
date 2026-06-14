# Architecture

## Components

- `frontend`: Flutter Web/App. 사용자 화면과 관리자 화면을 역할별 라우팅으로 구분합니다.
- `backend`: FastAPI REST API. API, service, model, schema 계층을 분리합니다.
- `mysql`: InnoDB 기반 영속 저장소입니다.
- `alembic`: SQLAlchemy 모델 변경 이력을 MySQL migration으로 관리합니다.

## Request Flow

```text
Flutter Widget
  -> Riverpod Notifier
  -> Repository
  -> Dio Client
  -> FastAPI Endpoint
  -> Service
  -> SQLAlchemy AsyncSession
  -> MySQL
```

## Gacha Transaction

가챠 요청은 다음 과정을 하나의 DB transaction에서 수행합니다.

1. `idempotency_key` 중복 여부를 확인합니다.
2. 사용자와 활성 배너를 검증합니다.
3. `wallets` 행을 `SELECT ... FOR UPDATE`로 잠급니다.
4. 재화를 차감하고 `wallet_transactions`에 기록합니다.
5. 천장 상태와 배너 확률을 적용해 결과를 생성합니다.
6. `gacha_sessions`, `gacha_results`에 원본 확률과 적용 확률을 기록합니다.
7. `inventories`를 갱신하고 `inventory_transactions`에 기록합니다.
8. `user_pity_states`를 갱신한 뒤 commit합니다.

중간 단계에서 실패하면 전체 transaction을 rollback합니다.
