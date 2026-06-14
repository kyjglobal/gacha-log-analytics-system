# 화면 명세

## 사용자 화면

| 화면 | Flutter Feature | 주요 API |
| --- | --- | --- |
| 로그인·회원가입 | `features/auth` | `/auth/*` |
| 대시보드 | `features/dashboard` | 가챠 배너·이력 데이터 |
| 가챠 | `features/gacha` | `/gacha/banners`, `/gacha/draw` |
| 가챠 이력 | `features/gacha` | `/gacha/history` |
| 인벤토리 | `features/inventory` | `/inventory` |
| 확률 통계 | `features/statistics` | `/statistics/me` |
| 랭킹 | `features/ranking` | `/rankings` |
| 확률 인증 작성 | `features/community` | `/community/certifications` |

## 랭킹 화면

- 활성 배너의 Luck Score 순위를 표시합니다.
- 현재 사용자의 순위와 행을 강조합니다.
- 기본 10회 이상의 가챠 표본을 가진 사용자만 표시합니다.
- 총 추첨 수, 신화 획득 수, 신화 획득 확률을 함께 표시합니다.
- 로그인하지 않은 사용자는 로그인 화면으로 이동할 수 있습니다.

## 커뮤니티 화면

| 화면 | 경로 | 기능 |
| --- | --- | --- |
| 커뮤니티 목록 | `/community` | 검색, 카테고리 필터, 게시글 목록 |
| 게시글 상세 | `/community/posts/:postId` | 상세, 조회수, 좋아요, 댓글 |
| 게시글 작성 | `/community/create` | 카테고리, 제목, 내용, 이미지 URL 작성 |
| 게시글 수정 | `/community/posts/:postId/edit` | 작성자 게시글 수정 |
| 로그인·회원가입 | `/auth` | JWT 인증 세션 생성 |
| 확률 인증 작성 | `/community/certify/:resultId` | 가챠 결과 확인 및 인증 게시글 작성 |

가챠 이력의 각 결과에서 인증 작성 화면으로 이동할 수 있습니다. 게시글 상세 화면은 서버가 검증한 아이템, 등급, 누적 추첨 수, 공식 확률, 개인 확률과 획득 시각을 표시합니다.

## 관리자 화면

| 화면 | Flutter Feature | 주요 API |
| --- | --- | --- |
| 종합 대시보드 | `features/admin` | `/admin/dashboard` |
| 사용자 관리 | `features/admin` | `/admin/users` |
| 아이템 지급·회수 | `features/admin` | `/admin/users/{id}/inventory-adjustments` |
| 로그 분석·삭제 | `features/admin` | `/admin/gacha-sessions` |

관리자 화면은 전체 사용자, 활성 사용자, 정지·차단 사용자, 유효 추첨 수와 삭제 로그 수를 표시합니다. 사용자 검색과 상태 변경, 아이템 ID 기반 수량 조정, 최근 가챠 세션 Soft Delete를 지원합니다.

## 반응형 정책

- 900px 이상: 고정 sidebar와 desktop layout
- 600px 이상 900px 미만: drawer와 축약 grid
- 600px 미만: 단일 column과 가로 스크롤 table
