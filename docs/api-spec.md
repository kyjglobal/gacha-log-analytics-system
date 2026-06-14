# REST API 명세

Base path: `/api/v1`

인증이 필요한 요청은 다음 헤더를 사용합니다.

```text
Authorization: Bearer <access_token>
```

## 인증

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| POST | `/auth/signup` | 불필요 | 회원가입, 초기 재화 지급, JWT 발급 |
| POST | `/auth/login` | 불필요 | 로그인 및 JWT 발급 |
| GET | `/auth/me` | 필요 | 현재 사용자 조회 |

## 가챠

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/gacha/banners` | 필요 | 활성 배너, 확률 풀, 재화, 천장 상태 조회 |
| POST | `/gacha/draw` | 필요 | 1회 또는 10회 추첨 실행 |
| GET | `/gacha/history` | 필요 | 사용자 추첨 세션 이력 조회 |
| GET | `/inventory` | 필요 | 사용자 인벤토리 조회 |

추첨 요청에는 중복 결제를 방지하는 헤더가 필요합니다.

```text
Idempotency-Key: <8-64 character unique key>
```

```json
{
  "banner_id": 1,
  "count": 10
}
```

가챠 실행은 재화 차감, 세션·결과 로그 생성, 인벤토리 증가, 천장 갱신을 하나의 DB 트랜잭션으로 처리합니다. 동일 사용자가 같은 `Idempotency-Key`로 재요청하면 기존 결과를 반환합니다.

가챠 이력 Query Parameter:

| 이름 | 기본값 | 설명 |
| --- | --- | --- |
| `page` | `1` | 페이지 번호 |
| `size` | `20` | 페이지 크기, 최대 50 |

인벤토리는 `rarity` Query Parameter로 `mythic`, `legendary`, `epic`, `rare`, `common`을 필터링할 수 있습니다.

## 확률 통계

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/statistics/me` | 필요 | 공식·개인·전체 사용자 확률과 Luck Score 조회 |

선택적 `banner_id` Query Parameter로 특정 배너를 조회할 수 있습니다. 생략하면 현재 활성 배너를 사용합니다.

응답은 다음 정보를 포함합니다.

- 개인과 전체 사용자의 유효 가챠 결과 표본 수
- 등급별 공식 확률
- 개인 획득 수와 실제 획득 확률
- 공식 확률 대비 개인 편차
- 전체 사용자의 획득 수와 실제 획득 확률
- 희귀도 가중 기대값 대비 개인 결과를 나타내는 Luck Score

삭제된 세션과 `completed` 상태가 아닌 세션은 통계에서 제외합니다.

## 랭킹

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/rankings` | 필요 | Luck Score 기반 사용자 랭킹과 내 순위 조회 |

Query Parameter:

| 이름 | 기본값 | 설명 |
| --- | --- | --- |
| `banner_id` | 활성 배너 | 조회할 가챠 배너 |
| `minimum_draws` | `10` | 랭킹 진입에 필요한 최소 추첨 수 |
| `limit` | `20` | 반환할 사용자 수, 최대 100 |

랭킹은 Luck Score 내림차순으로 정렬하며, 점수가 같으면 총 추첨 수가 많은 사용자가 우선합니다. 탈퇴·정지 사용자와 삭제되거나 완료되지 않은 가챠 세션은 제외합니다.

## 커뮤니티

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/community/posts` | 불필요 | 게시글 목록, 검색, 카테고리 필터 |
| GET | `/community/posts/{post_id}` | 불필요 | 게시글 상세 및 조회수 증가 |
| POST | `/community/posts` | 필요 | 게시글 작성 |
| PUT | `/community/posts/{post_id}` | 필요 | 작성자 또는 관리자 게시글 수정 |
| DELETE | `/community/posts/{post_id}` | 필요 | 게시글 Soft Delete |
| POST | `/community/posts/{post_id}/like` | 필요 | 좋아요 추가 또는 취소 |
| GET | `/community/posts/{post_id}/comments` | 불필요 | 댓글 목록 |
| POST | `/community/posts/{post_id}/comments` | 필요 | 댓글 작성 |
| PUT | `/community/comments/{comment_id}` | 필요 | 댓글 수정 |
| DELETE | `/community/comments/{comment_id}` | 필요 | 댓글 Soft Delete |

## 미구현 API

- 확률 인증 게시글과 가챠 결과 자동 첨부
- 관리자 사용자·로그 제어
