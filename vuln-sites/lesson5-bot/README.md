# Lesson 5 Bot-Mitigation Backend

This dependency-free Python service provides the deterministic browser, crawler, scraper, login, API, error, and timing paths used by the FortiWeb Lesson 5 bot-mitigation lab.

```text
bot.lab.local -> route_bot_l5 -> pool_bot_l5 -> 10.0.20.2:8004
```

## Run

```bash
cd vuln-sites/lesson5-bot
chmod +x bot_server.py
nohup python3 bot_server.py > bot_server.log 2>&1 &
echo $! > bot_server.pid
sudo ss -lntp | grep ':8004'
curl -i http://127.0.0.1:8004/health
```

The service listens on `0.0.0.0:8004`. Its runtime log records the TCP peer, `X-Forwarded-For`, method, path, User-Agent, and cookie header. The report records FortiWeb-routed requests as backend TCP peer `10.0.20.1` with original client `10.0.11.2` in `X-Forwarded-For`.

## Local baseline

```bash
curl -i -X POST http://127.0.0.1:8004/login -H 'Content-Type: application/json' --data '{"username":"demo","password":"FortiWeb123!"}'
curl -i -X POST http://127.0.0.1:8004/login -H 'Content-Type: application/json' --data '{"username":"bad","password":"bad"}'
```

Lab-only credentials: `demo` / `FortiWeb123!`. The intended responses are `200` authenticated and `401` denied.

## Endpoint map

| Path | Purpose |
| --- | --- |
| `/`, `/search`, `/login` | Browser interaction and clean ML-training pages |
| `/health` | Pool health and post-block recovery |
| `/products`, `/product/1` ... `/product/20` | Crawlable catalogue and content-scraping target |
| `/api/items` | JSON path for mixed ML automation |
| `/headers` | Backend-visible TCP/client header/cookie proof |
| `/forbidden`, `/missing/*` | Controlled `403` and `404` crawler/error paths |
| `/robots.txt`, `/slow` | Crawler guidance and two-second timing response |

## Stop and clean up

```bash
kill "$(cat bot_server.pid)"
rm -f bot_server.pid bot_server.log
```

Do not commit runtime logs or PID files: FortiWeb cookies may appear in logs during routed validation.
