# 기여 가이드

이 저장소의 모든 변경은 `main`, `develop`, `feature/*` 브랜치 전략과 지정된 커밋 메시지 규칙을 따릅니다.

## 시작하기

```powershell
git switch develop
git pull origin develop
git switch -c feature/<기능명>
```

브랜치 예시:

```text
feature/auth
feature/gacha
feature/inventory
feature/statistics
feature/community
feature/admin
feature/docs
```

## 브랜치 규칙

- `main`: 항상 배포 가능한 상태를 유지합니다.
- `develop`: 완료된 기능을 통합하는 브랜치입니다.
- `feature/*`: 모든 기능 개발, 수정, 문서 작업을 수행하는 브랜치입니다.
- `feature/*`는 `develop`에서 생성하고 `develop`으로 Pull Request를 보냅니다.
- 릴리스 시에만 `develop`을 `main`으로 병합합니다.
- `main`과 `develop`에는 직접 커밋하지 않습니다.
- 하나의 feature 브랜치는 하나의 목적만 가집니다.

## 커밋 메시지

형식:

```text
type(scope): 한국어 설명
```

규칙:

- `type`과 `scope`는 영어로 작성합니다.
- 설명은 한국어로 작성합니다.
- 설명은 변경 결과가 드러나도록 간결하게 작성합니다.
- 마침표는 생략합니다.

허용되는 type:

| Type | 용도 |
| --- | --- |
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변경 없는 코드 구조 개선 |
| `style` | 코드 포맷 및 스타일 수정 |
| `docs` | 문서 수정 |
| `test` | 테스트 추가 및 수정 |
| `chore` | 설정, 의존성 및 개발 환경 관리 |

허용되는 scope:

| 영역 | Scope |
| --- | --- |
| Frontend | `auth`, `gacha`, `inventory`, `statistics`, `community`, `admin`, `frontend` |
| Backend | `backend`, `api`, `database`, `user` |
| Project | `docs`, `docker`, `erd`, `project` |

올바른 예시:

```text
feat(auth): JWT 로그인 기능 구현
feat(community): 확률 인증 게시글 기능 추가
fix(gacha): 천장 횟수 초기화 오류 수정
docs(api): 커뮤니티 API 명세 작성
```

잘못된 예시:

```text
feat(auth): implement JWT login
기능추가(auth): JWT 로그인 구현
feat(Auth): JWT 로그인 기능 구현
```

## 로컬 Git 설정

저장소를 처음 clone한 뒤 한 번 실행합니다.

```powershell
git config commit.template .gitmessage.txt
git config core.hooksPath .githooks
```

이 설정은 커밋 작성 시 템플릿을 표시하고, 커밋 메시지가 규칙을 위반하면 커밋을 차단합니다.
GitHub Actions도 Pull Request의 브랜치 흐름과 커밋 메시지를 다시 검증합니다.

## 개발 절차

1. `develop`을 최신 상태로 갱신합니다.
2. `feature/*` 브랜치를 생성합니다.
3. 기능 구현과 테스트를 완료합니다.
4. 규칙에 맞는 단위로 커밋합니다.
5. 원격 feature 브랜치에 push합니다.
6. `develop`을 대상으로 Pull Request를 생성합니다.
7. 리뷰와 CI 검증 후 병합합니다.

## 테스트 기준

Frontend:

```powershell
cd frontend
flutter analyze
flutter test
```

Backend:

```powershell
cd backend
pytest
```

Docker:

```powershell
docker compose config
```

실행하지 못한 테스트가 있다면 Pull Request의 `테스트 결과`에 이유를 명시합니다.

## Pull Request

- 기본 대상 브랜치는 `develop`입니다.
- 릴리스 Pull Request만 `main`을 대상으로 합니다.
- 변경 목적, 주요 변경점, 테스트 결과, 관련 이슈를 작성합니다.
- 관련 이슈는 `Closes #번호` 또는 `Refs #번호` 형식을 사용합니다.
- API, DB, UI 계약 변경은 관련 `docs/` 문서도 함께 수정합니다.

상세 규칙은 [docs/git-strategy.md](docs/git-strategy.md)를 확인합니다.
