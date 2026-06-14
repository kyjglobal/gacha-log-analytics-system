# REST API 명세

Base path: `/api/v1`

## 인증

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| POST | `/auth/signup` | 불필요 | 회원가입 및 JWT 발급 |
| POST | `/auth/login` | 불필요 | 로그인 및 JWT 발급 |
| GET | `/auth/me` | 필요 | 현재 사용자 조회 |

인증이 필요한 요청은 다음 헤더를 사용합니다.

```text
Authorization: Bearer <access_token>
```

## 커뮤니티 게시글

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/community/posts` | 불필요 | 게시글 목록, 카테고리 필터, 검색, 페이지네이션 |
| GET | `/community/posts/{post_id}` | 불필요 | 게시글 상세 및 조회수 증가 |
| POST | `/community/posts` | 필요 | 게시글 작성 |
| PUT | `/community/posts/{post_id}` | 필요 | 작성자 또는 관리자 게시글 수정 |
| DELETE | `/community/posts/{post_id}` | 필요 | 작성자 또는 관리자 Soft Delete |
| POST | `/community/posts/{post_id}/like` | 필요 | 좋아요 추가 또는 취소 |

목록 Query Parameter:

| 이름 | 기본값 | 설명 |
| --- | --- | --- |
| `page` | `1` | 페이지 번호 |
| `size` | `20` | 페이지 크기, 최대 100 |
| `category` | 없음 | 커뮤니티 카테고리 |
| `search` | 없음 | 제목 및 내용 검색 |

카테고리:

```text
확률 인증
가챠 자랑
통계 분석
공략 및 팁
자유 게시판
```

게시글 작성 예시:

```json
{
  "title": "80회 이전 신화 획득",
  "content": "누적 62회에서 신화 아이템을 획득했습니다.",
  "category": "확률 인증",
  "image_url": "https://example.com/result.png"
}
```

## 커뮤니티 댓글

| Method | Path | 인증 | 설명 |
| --- | --- | --- | --- |
| GET | `/community/posts/{post_id}/comments` | 불필요 | 댓글 목록 |
| POST | `/community/posts/{post_id}/comments` | 필요 | 댓글 작성 |
| PUT | `/community/comments/{comment_id}` | 필요 | 작성자 또는 관리자 댓글 수정 |
| DELETE | `/community/comments/{comment_id}` | 필요 | 작성자 또는 관리자 댓글 Soft Delete |

## 기존 도메인 API 계획

| Method | Path | 설명 |
| --- | --- | --- |
| GET | `/banners` | 활성 가챠 배너 조회 |
| POST | `/gacha/draw` | 1회 또는 10회 가챠 실행 |
| GET | `/gacha/history` | 사용자 가챠 로그 조회 |
| GET | `/inventory` | 인벤토리 조회 |
| GET | `/statistics/me` | 개인 확률 통계 |
| GET | `/rankings` | 공개 사용자 랭킹 |

위 기존 도메인 API는 아직 구현 예정입니다.

## 다음 커뮤니티 단계

- `ProbabilityCertification` 모델
- 가챠 결과, 인벤토리, 가챠 이력 기반 확률 인증
- 커뮤니티 평균 확률과 Luck Score
- 인기 아이템과 인기 게시글 통계
- 이미지 파일 업로드 저장소 연동
