# REST API Draft

Base path: `/api/v1`

## Authentication

| Method | Path | Description |
| --- | --- | --- |
| POST | `/auth/signup` | 회원가입 |
| POST | `/auth/login` | JWT access/refresh token 발급 |
| POST | `/auth/refresh` | access token 재발급 |
| GET | `/users/me` | 내 계정 조회 |
| PATCH | `/users/me` | 계정 정보 수정 |
| DELETE | `/users/me` | 회원 논리 삭제 |

## Gacha and Inventory

| Method | Path | Description |
| --- | --- | --- |
| GET | `/banners` | 활성 가챠 배너 조회 |
| POST | `/gacha/draw` | 1회 또는 10회 가챠 실행 |
| GET | `/gacha/history` | 사용자 가챠 로그 조회 |
| GET | `/inventory` | 인벤토리 목록과 등급 필터 |
| GET | `/statistics/me` | 개인 공식/실제 확률 비교 |
| GET | `/rankings` | 공개 유저 랭킹 |

`POST /gacha/draw`는 `Idempotency-Key` 헤더를 필수로 받습니다.

```json
{
  "banner_id": 1,
  "count": 10
}
```

## Admin

| Method | Path | Description |
| --- | --- | --- |
| GET | `/admin/dashboard` | 시스템 집계 지표 |
| GET | `/admin/users` | 사용자 검색 및 정렬 |
| PATCH | `/admin/users/{user_id}/status` | 정지 및 차단 상태 변경 |
| GET | `/admin/gacha-logs` | 전체 가챠 로그 검색 |
| DELETE | `/admin/gacha-logs/{session_id}` | 로그 논리 삭제 |
| POST | `/admin/inventory/adjustments` | 아이템 수동 지급 및 회수 |

관리자 변경 작업은 별도 감사 로그에 요청자, 대상, 변경 전후 값, 사유를 기록합니다.
