# Gacha Log Analysis System

대용량 가챠 로그의 적재, 인벤토리 관리, 확률 분석 및 관리자 기능을 제공하는 프로젝트입니다.

## Structure

```text
DBP/
├── frontend/       # Flutter Web/App
├── backend/        # FastAPI + SQLAlchemy + Alembic
├── docs/           # 화면, ERD, API 및 아키텍처 명세
└── docker-compose.yml
```

## Run

1. 필요하면 `.env.example`을 `.env`로 복사해 기본 설정을 변경합니다.
2. MySQL과 FastAPI를 실행합니다. `.env`가 없어도 로컬 기본값으로 실행됩니다.

```powershell
docker compose up --build
```

3. 다른 터미널에서 Flutter를 실행합니다.

```powershell
cd frontend
flutter run -d chrome
```

- FastAPI Swagger: http://localhost:8000/docs
- Health check: http://localhost:8000/health

현재 Flutter는 로컬 데모 데이터를 사용합니다. 다음 구현 단계에서 Dio repository를 통해 FastAPI API로 교체합니다.
