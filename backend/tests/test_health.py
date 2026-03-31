from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_returns_200_and_healthy():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data


def test_assets_returns_200():
    response = client.get("/assets")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_insights_returns_200():
    response = client.get("/insights")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_cors_allowed_origin():
    response = client.options(
        "/health",
        headers={
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.headers.get("access-control-allow-origin") == "http://localhost:3000"


def test_cors_disallowed_origin():
    response = client.options(
        "/health",
        headers={
            "Origin": "https://evil.com",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.headers.get("access-control-allow-origin") != "https://evil.com"


def test_unknown_route_returns_404():
    response = client.get("/does-not-exist")
    assert response.status_code == 404
