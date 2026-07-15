#!/usr/bin/env python3
"""Deterministic backend for the isolated FortiWeb Lesson 5 bot-mitigation lab."""

from __future__ import annotations

import json
import time
from datetime import datetime, timezone
from html import escape
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

HOST = "0.0.0.0"
PORT = 8004
LAB_USERNAME = "demo"
LAB_PASSWORD = "FortiWeb123!"


class BotLabHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "Lesson5BotBackend/1.0"

    def log_transaction(self) -> None:
        print(
            "[REQUEST] "
            f"time={datetime.now(timezone.utc).isoformat()} "
            f"tcp_client={self.client_address[0]} "
            f"xff={self.headers.get('X-Forwarded-For', '-')!r} "
            f"method={self.command} path={self.path!r} "
            f"user_agent={self.headers.get('User-Agent', '-')!r} "
            f"cookie={self.headers.get('Cookie', '-')!r}",
            flush=True,
        )

    def send_payload(self, status, body, content_type, extra_headers=None) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        for name, value in (extra_headers or {}).items():
            self.send_header(name, value)
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def send_html(self, status, html, extra_headers=None) -> None:
        self.send_payload(status, html.encode(), "text/html; charset=utf-8", extra_headers)

    def send_json(self, status, data) -> None:
        self.send_payload(status, json.dumps(data, indent=2).encode(), "application/json")

    def do_HEAD(self) -> None:  # noqa: N802
        self.do_GET()

    def do_GET(self) -> None:  # noqa: N802
        self.log_transaction()
        parsed = urlparse(self.path)
        path, query = parsed.path, parse_qs(parsed.query)

        if path == "/health":
            self.send_json(200, {"status": "ok", "lesson": 5, "service": "bot-mitigation-backend"})
        elif path == "/":
            self.send_html(200, """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>FortiWeb Lesson 5 Bot Mitigation Lab</title>
<style>body{font-family:Arial,sans-serif;margin:40px;line-height:1.5}#activity{padding:12px;margin:20px 0;background:#eee}li{margin:8px 0}</style>
</head><body><h1>FortiWeb Lesson 5 - Bot Mitigation</h1>
<p>This controlled application provides predictable traffic for browser, crawler, scraper, login automation, API, and threshold tests.</p>
<div id="activity">Interact with this page using the mouse, keyboard, or scrolling.</div>
<form action="/search" method="GET"><label>Product search: <input name="q" type="text" value="camera"></label><button type="submit">Search</button></form>
<ul><li><a href="/products">Product catalogue</a></li><li><a href="/login">Login workflow</a></li><li><a href="/api/items">JSON API</a></li><li><a href="/headers">Headers observed by the backend</a></li><li><a href="/forbidden">403 test</a></li><li><a href="/missing/example">404 test</a></li><li><a href="/slow">Slow endpoint</a></li></ul>
<script>const activity=document.getElementById("activity");let eventCount=0;function recordEvent(n){eventCount+=1;activity.textContent="Browser interaction events observed locally: "+eventCount+" - latest event: "+n}document.addEventListener("mousemove",()=>recordEvent("mousemove"));document.addEventListener("keydown",()=>recordEvent("keydown"));document.addEventListener("scroll",()=>recordEvent("scroll"));document.addEventListener("touchstart",()=>recordEvent("touchstart"));</script>
</body></html>""", {"Set-Cookie": "botlab_visit=1; Path=/; HttpOnly; SameSite=Lax"})
        elif path == "/products":
            links = "\n".join(f'<li><a href="/product/{n}">Lesson 5 Product {n}</a></li>' for n in range(1, 21))
            self.send_html(200, f"<h1>Product Catalogue</h1><p>This page provides multiple crawlable product links.</p><ul>{links}</ul><a href='/'>Return home</a>")
        elif path.startswith("/product/"):
            product_id = path.removeprefix("/product/")
            if product_id.isdigit():
                self.send_html(200, f"<h1>Lesson 5 Product {escape(product_id)}</h1><p>Price: ${int(product_id) * 10}.00</p><p>This deterministic page is a content-scraping target.</p><a href='/products'>Return to catalogue</a>")
            else:
                self.send_html(404, "<h1>404 - Invalid product</h1>")
        elif path == "/search":
            search_value = escape(query.get("q", [""])[0])
            self.send_html(200, f"<h1>Search Results</h1><p>Search query: <strong>{search_value}</strong></p><p>Three controlled results were returned.</p><a href='/'>Return home</a>")
        elif path == "/login":
            self.send_html(200, """<h1>Bot Mitigation Login Test</h1><p>Valid laboratory credentials: demo / FortiWeb123!</p><form action='/login' method='POST'><label>Username: <input name='username' type='text'></label><br><label>Password: <input name='password' type='password'></label><br><button type='submit'>Log in</button></form>""")
        elif path == "/api/items":
            self.send_json(200, {"items": [{"id": n, "name": f"Bot Lab Item {n}"} for n in range(1, 11)], "count": 10})
        elif path == "/headers":
            cookies = SimpleCookie(); cookies.load(self.headers.get("Cookie", ""))
            self.send_json(200, {"tcp_client_seen_by_backend": self.client_address[0], "x_forwarded_for": self.headers.get("X-Forwarded-For"), "user_agent": self.headers.get("User-Agent"), "accept": self.headers.get("Accept"), "accept_language": self.headers.get("Accept-Language"), "cookie_names": sorted(cookies.keys()), "request_path": self.path})
        elif path == "/forbidden":
            self.send_html(403, "<h1>403 - Forbidden</h1><p>This controlled response supports repeated-403 bot tests.</p>")
        elif path == "/robots.txt":
            self.send_payload(200, b"User-agent: *\nAllow: /\nDisallow: /admin/\nDisallow: /internal/\n", "text/plain; charset=utf-8")
        elif path == "/slow":
            time.sleep(2); self.send_html(200, "<h1>Slow Response Completed</h1><p>The backend deliberately waited two seconds.</p>")
        else:
            self.send_html(404, "<h1>404 - Not Found</h1><p>This controlled response supports repeated-404 bot tests.</p>")

    def do_POST(self) -> None:  # noqa: N802
        self.log_transaction()
        raw_body = self.rfile.read(int(self.headers.get("Content-Length", "0")))
        if urlparse(self.path).path != "/login":
            self.send_json(404, {"error": "unknown POST endpoint"})
            return
        try:
            if "application/json" in self.headers.get("Content-Type", ""):
                submitted = json.loads(raw_body or b"{}")
            else:
                form = parse_qs(raw_body.decode(errors="replace"), keep_blank_values=True)
                submitted = {key: values[0] if values else "" for key, values in form.items()}
        except (json.JSONDecodeError, UnicodeDecodeError):
            self.send_json(400, {"error": "malformed request"})
            return
        if submitted.get("username") == LAB_USERNAME and submitted.get("password") == LAB_PASSWORD:
            self.send_json(200, {"status": "authenticated", "username": LAB_USERNAME})
        else:
            self.send_json(401, {"status": "denied", "message": "Invalid laboratory credentials"})

    def log_message(self, message_format, *args) -> None:
        print(f"[HTTP] client={self.client_address[0]} message={message_format % args}", flush=True)


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), BotLabHandler)
    print(f"FortiWeb Lesson 5 bot backend listening on {HOST}:{PORT}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
