# 데모 데이터 안내

`0004_seed_demo_activity` 마이그레이션은 화면과 API를 바로 확인할 수 있는 연결형 데모 데이터를 생성합니다.

## 테스트 계정

모든 계정의 비밀번호는 `Demo1234!`입니다.

| 역할 | 이메일 | 닉네임 |
| --- | --- | --- |
| 일반 사용자 | `demo@gacha.local` | 별빛여행자 |
| 일반 사용자 | `lucky@gacha.local` | 행운의손 |
| 일반 사용자 | `analyst@gacha.local` | 확률분석가 |
| 일반 사용자 | `collector@gacha.local` | 도감수집가 |
| 일반 사용자 | `casual@gacha.local` | 퇴근후한뽑 |
| 관리자 | `admin@gacha.local` | 운영관리자 |

## 포함 데이터

- 활성 사용자 6명
- 천상의 궤적 배너 가챠 결과 520회
- 사용자별 가챠 세션, 재화 거래, 천장 상태, 인벤토리
- 랭킹과 개인·커뮤니티 확률 통계 집계용 데이터
- 커뮤니티 게시글 10개
- 확률 인증 게시글 2개
- 게시글 댓글과 좋아요

## 적용

```bash
docker compose up -d
docker compose exec backend alembic upgrade head
```

데이터베이스 볼륨을 새로 만들면 전체 마이그레이션과 데모 데이터가 자동 적용됩니다.
