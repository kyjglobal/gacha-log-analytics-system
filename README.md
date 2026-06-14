# Gacha Log Analytics System

대용량 가챠 로그 적재, 사용자 인벤토리 관리, 공식 확률과 실제 획득 확률 비교, 관리자 백오피스를 제공하는 프로젝트입니다.

## 프로젝트 구조

```text
DBP/
├── frontend/       # Flutter Web/App
├── backend/        # FastAPI + SQLAlchemy + Alembic
├── docs/           # 화면, ERD, API, 아키텍처 명세
└── docker-compose.yml
```

## 실행

필요하면 `.env.example`을 `.env`로 복사해 기본 설정을 변경합니다.

MySQL과 FastAPI:

```powershell
docker compose up --build
```

Flutter:

```powershell
cd frontend
flutter run -d chrome
```

다른 API 주소를 사용하려면 compile-time 환경변수를 지정합니다.

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

- FastAPI Swagger: http://localhost:8000/docs
- Health check: http://localhost:8000/health
- Community: Flutter sidebar의 `Community`

## 개발 규칙

- 기여 절차: [CONTRIBUTING.md](CONTRIBUTING.md)
- Git 브랜치 및 커밋 전략: [docs/git-strategy.md](docs/git-strategy.md)
- API 초안: [docs/api-spec.md](docs/api-spec.md)
- ERD: [docs/erd.md](docs/erd.md)

모든 개발은 `develop`에서 생성한 `feature/*` 브랜치에서 수행합니다. 커밋 메시지는 `type(scope): 한국어 설명` 형식을 사용합니다.
