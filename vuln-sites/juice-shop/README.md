# Juice Shop Backends

Two Juice Shop instances support pool, round-robin, and source-IP persistence testing.

```bash
docker compose up -d
docker compose ps
curl -I http://127.0.0.1:3000
curl -I http://127.0.0.1:3001
```

FortiWeb pool members:

```text
10.0.20.2:3000
10.0.20.2:3001
```

Cleanup:

```bash
docker compose down
```

