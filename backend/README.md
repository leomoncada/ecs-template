# Portfolio API (Backend)

FastAPI backend for the Portfolio Dashboard. Serves financial asset data and portfolio metrics.

## Endpoints

- `GET /health` — Health check (status, version)
- `GET /assets` — List assets (mock data)
- `GET /insights` — Portfolio metrics derived from assets

## Run locally

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API available at http://localhost:8000. Docs at http://localhost:8000/docs.
