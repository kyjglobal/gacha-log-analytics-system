from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_check() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_openapi_contains_auth_and_community_routes() -> None:
    response = client.get("/openapi.json")
    paths = response.json()["paths"]

    assert "/api/v1/auth/login" in paths
    assert "/api/v1/community/posts" in paths
    assert "/api/v1/community/posts/{post_id}/comments" in paths
