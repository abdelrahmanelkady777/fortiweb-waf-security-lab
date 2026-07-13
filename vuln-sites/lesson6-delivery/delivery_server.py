#!/usr/bin/env python3
"""Deterministic application-delivery backend for FortiWeb Lesson 6.

The service intentionally exposes public, redirect, private, static, slow, and
capacity-limited paths so FortiWeb transformations can be proved independently
of application logic. It uses only the Python standard library.
"""

from __future__ import annotations

import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


HOST = "0.0.0.0"
PORT = 8003
BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"
LARGE_TEXT = STATIC_DIR / "large.txt"
LARGE_TEXT_LINE = (
    "FortiWeb Lesson 6 compression and caching test content. "
    "This sentence is intentionally repeated to compress efficiently.\n"
)

request_counter = 0


def ensure_static_assets() -> None:
    """Create the repeatable large text object when it is not present."""
    STATIC_DIR.mkdir(parents=True, exist_ok=True)
    if not LARGE_TEXT.exists():
        LARGE_TEXT.write_text(LARGE_TEXT_LINE * 700, encoding="utf-8")


class DeliveryHandler(BaseHTTPRequestHandler):
    """Serve controlled Lesson 6 endpoints and log the backend-visible path."""

    protocol_version = "HTTP/1.1"
    server_version = "Lesson6Backend/1.0"

    def send_body(
        self,
        status: int,
        body: bytes,
        content_type: str = "text/html; charset=utf-8",
        *,
        cache_control: str = "no-cache",
        extra_headers: dict[str, str] | None = None,
    ) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", cache_control)

        if extra_headers:
            for name, value in extra_headers.items():
                self.send_header(name, value)

        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def send_html(
        self,
        html: str,
        status: int = 200,
        *,
        cache_control: str = "no-cache",
        extra_headers: dict[str, str] | None = None,
    ) -> None:
        self.send_body(
            status,
            html.encode("utf-8"),
            "text/html; charset=utf-8",
            cache_control=cache_control,
            extra_headers=extra_headers,
        )

    def do_HEAD(self) -> None:  # noqa: N802 - stdlib handler API
        self.do_GET()

    def do_GET(self) -> None:  # noqa: N802 - stdlib handler API
        global request_counter

        parsed = urlparse(self.path)
        path = parsed.path

        print(
            f"[REQUEST] client={self.client_address[0]} "
            f"method={self.command} host={self.headers.get('Host')} path={path}",
            flush=True,
        )

        if path == "/":
            self.send_html(
                """<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>FortiWeb Lesson 6</title>
  <link rel="stylesheet" href="/static/style.css">
</head>
<body>
  <h1>FortiWeb Lesson 6 - Application Delivery</h1>
  <p>This backend is running on 10.0.20.2:8003.</p>
  <ul>
    <li><a href="/old">Redirect test source</a></li>
    <li><a href="/new">Redirect destination</a></li>
    <li><a href="/legacy/page">Request rewrite source</a></li>
    <li><a href="/modern/page">Request rewrite destination</a></li>
    <li><a href="/backend-links">Response rewriting test</a></li>
    <li><a href="/backend-redirect">Location header rewriting test</a></li>
    <li><a href="/private/">Private application</a></li>
    <li><a href="/counter">Backend request counter</a></li>
    <li><a href="/headers">Request headers</a></li>
    <li><a href="/slow">Slow response</a></li>
    <li><a href="/sale">Waiting-room target</a></li>
    <li><a href="/static/large.txt">Compression and cache target</a></li>
  </ul>
  <script src="/static/app.js"></script>
</body>
</html>"""
            )
            return

        if path == "/old":
            self.send_html(
                """<html><body><h1>Backend /old page</h1>
<p>FortiWeb has not redirected this request yet.</p></body></html>"""
            )
            return

        if path == "/new":
            self.send_html(
                """<html><body><h1>Redirect Destination</h1>
<p>The client reached /new successfully.</p></body></html>"""
            )
            return

        if path == "/legacy/page":
            self.send_html(
                """<html><body><h1>Legacy Backend Page</h1>
<p>The backend received /legacy/page directly.</p></body></html>"""
            )
            return

        if path == "/modern/page":
            self.send_html(
                """<html><body><h1>Modern Backend Page</h1>
<p>The backend received /modern/page.</p></body></html>"""
            )
            return

        if path == "/backend-links":
            self.send_html(
                """<html><body><h1>Response Rewriting Test</h1>
<p>The following links intentionally expose the internal backend:</p>
<a href="http://10.0.20.2:8003/private/">Internal private application</a><br>
<a href="http://10.0.20.2:8003/new">Internal redirect destination</a>
</body></html>"""
            )
            return

        if path == "/backend-redirect":
            self.send_body(
                302,
                b"Backend redirect response",
                "text/plain; charset=utf-8",
                extra_headers={"Location": "http://10.0.20.2:8003/new"},
            )
            return

        if path in ("/private", "/private/"):
            self.send_html(
                """<html><body><h1>Protected Private Application</h1>
<p>If Site Publishing is active, FortiWeb authenticates the user before this
page is returned.</p></body></html>"""
            )
            return

        if path == "/counter":
            request_counter += 1
            response = {
                "backend_request_count": request_counter,
                "message": (
                    "This number increases only when the request reaches the backend."
                ),
            }
            self.send_body(
                200,
                json.dumps(response, indent=2).encode("utf-8"),
                "application/json",
                cache_control="public, max-age=120",
                extra_headers={"X-Backend-Request-Count": str(request_counter)},
            )
            return

        if path == "/headers":
            response = {
                "client_ip_seen_by_backend": self.client_address[0],
                "request_path": self.path,
                "headers": dict(self.headers.items()),
            }
            self.send_body(
                200,
                json.dumps(response, indent=2).encode("utf-8"),
                "application/json",
            )
            return

        if path == "/slow":
            time.sleep(3)
            self.send_html(
                """<html><body><h1>Slow Response Completed</h1>
<p>The backend deliberately waited three seconds.</p></body></html>"""
            )
            return

        if path == "/sale":
            time.sleep(8)
            self.send_html(
                """<html><body><h1>Lesson 6 Limited-Capacity Sale</h1>
<p>This request occupied a backend worker for eight seconds.</p></body></html>"""
            )
            return

        static_files = {
            "/static/app.js": ("app.js", "application/javascript"),
            "/static/style.css": ("style.css", "text/css"),
            "/static/large.txt": ("large.txt", "text/plain; charset=utf-8"),
        }
        if path in static_files:
            filename, content_type = static_files[path]
            body = (STATIC_DIR / filename).read_bytes()
            self.send_body(
                200,
                body,
                content_type,
                cache_control="public, max-age=300",
            )
            return

        self.send_html(
            """<html><body><h1>404 - Not Found</h1>
<p>The Lesson 6 backend does not contain this path.</p></body></html>""",
            status=404,
        )

    def log_message(self, format: str, *args: object) -> None:
        print(f"[HTTP] {self.client_address[0]} - {format % args}", flush=True)


if __name__ == "__main__":
    ensure_static_assets()
    server = ThreadingHTTPServer((HOST, PORT), DeliveryHandler)
    print(f"Lesson 6 application-delivery backend listening on {HOST}:{PORT}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
