# Screen Specification

## User

| Screen | Flutter Feature | Main API |
| --- | --- | --- |
| 로그인/회원가입 | `features/auth` | `/auth/*` |
| 대시보드 | `features/dashboard` | `/users/me`, `/statistics/me` |
| 가챠 | `features/gacha` | `/banners`, `/gacha/draw` |
| 인벤토리 | `features/inventory` | `/inventory` |
| 확률 통계 | `features/statistics` | `/statistics/me` |
| 랭킹 | `features/ranking` | `/rankings` |
| 계정 관리 | `features/account` | `/users/me` |

## Admin

| Screen | Flutter Feature | Main API |
| --- | --- | --- |
| 종합 대시보드 | `features/admin/dashboard` | `/admin/dashboard` |
| 사용자 관리 | `features/admin/users` | `/admin/users` |
| 로그 분석 | `features/admin/logs` | `/admin/gacha-logs` |
| 아이템 지급/회수 | `features/admin/inventory` | `/admin/inventory/adjustments` |

## Responsive Policy

- 900px 이상: 고정 sidebar와 desktop table을 사용합니다.
- 600px 이상 900px 미만: drawer와 축약된 grid를 사용합니다.
- 600px 미만: 단일 column, bottom-safe padding, 가로 스크롤 table을 사용합니다.
