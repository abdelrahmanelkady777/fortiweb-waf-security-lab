# Lesson 4 Controlled API

This dependency-free Python API provides deterministic JSON, XML, GraphQL, OpenAPI, JWT, and rate-limit targets for the FortiWeb Lesson 4 lab.

## Run

```bash
cd lesson4-api
python3 api_server.py
```

The service listens on `0.0.0.0:8002`.

```bash
curl -i http://127.0.0.1:8002/health
curl -i -X POST http://127.0.0.1:8002/api/register \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","email":"kady@example.com","password":"Pass123!","age":22}'
curl -i -X POST http://127.0.0.1:8002/api/login \
  -H "Content-Type: application/json" \
  --data '{"username":"kady","password":"Pass123!"}'
```

Lab-only credentials: `kady` / `Pass123!`.

FortiWeb mapping:

```text
api.lab.local -> route_api_lesson4 -> pool_api_lesson4 -> 10.0.20.2:8002
```

The backend is intentionally permissive about request shape and CORS so FortiWeb can demonstrate enforcement. It never expands XML external entities or executes submitted data.

