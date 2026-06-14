# 화면 명세

## 사용자 화면

| 화면 | Flutter Feature | 주요 API |
| --- | --- | --- |
| 로그인/회원가입 | `features/auth` | `/auth/*` |
| 대시보드 | `features/dashboard` | 구현 예정 |
| 가챠 | `features/gacha` | 구현 예정 |
| 인벤토리 | `features/inventory` | 구현 예정 |
| 확률 통계 | `features/statistics` | 구현 예정 |
| 랭킹 | `features/ranking` | 구현 예정 |

## 커뮤니티 화면

| 화면 | 경로 | 기능 |
| --- | --- | --- |
| 커뮤니티 목록 | `/community` | 검색, 카테고리 필터, 게시글 목록 |
| 게시글 상세 | `/community/posts/:postId` | 상세, 조회수, 좋아요, 댓글 |
| 게시글 작성 | `/community/create` | 카테고리, 제목, 내용, 이미지 URL 작성 |
| 게시글 수정 | `/community/posts/:postId/edit` | 작성자 게시글 수정 |
| 로그인/회원가입 | `/auth` | JWT 인증 세션 생성 |

## 관리자 화면

| 화면 | Flutter Feature | 주요 API |
| --- | --- | --- |
| 종합 대시보드 | `features/admin` | 구현 예정 |
| 사용자 관리 | `features/admin` | 구현 예정 |
| 로그 분석 | `features/admin` | 구현 예정 |

## 반응형 정책

- 900px 이상: 고정 sidebar와 desktop layout
- 600px 이상 900px 미만: drawer와 축약 grid
- 600px 미만: 단일 column과 가로 스크롤 테이블
