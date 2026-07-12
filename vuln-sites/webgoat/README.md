# WebGoat Backend

```bash
docker compose up -d
docker compose ps
curl -I http://127.0.0.1:8080/WebGoat
```

FortiWeb pool member:

```text
10.0.20.2:8080
```

A redirect to `/WebGoat/` is normal.

Cleanup:

```bash
docker compose down
```

