"""Dependency-free API backend for the FortiWeb Lesson 4 lab."""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


HOST = "0.0.0.0"
PORT = 8002
JWT_SECRET = b"lesson4-secret"
BASE_DIR = Path(__file__).resolve().parent


def b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def b64url_decode(value: str) -> bytes:
    value += "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value.encode("ascii"))


def issue_token(username: str) -> str:
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": username,
        "role": "student",
        "iat": int(time.time()),
        "exp": int(time.time()) + 3600,
    }
    encoded_header = b64url_encode(json.dumps(header, separators=(",", ":")).encode())
    encoded_payload = b64url_encode(json.dumps(payload, separators=(",", ":")).encode())
    signing_input = f"{encoded_header}.{encoded_payload}".encode()
    signature = hmac.new(JWT_SECRET, signing_input, hashlib.sha256).digest()
    return f"{encoded_header}.{encoded_payload}.{b64url_encode(signature)}"


def verify_token(token: str) -> dict[str, object] | None:
    try:
        encoded_header, encoded_payload, encoded_signature = token.split(".")
        signing_input = f"{encoded_header}.{encoded_payload}".encode()
        expected = hmac.new(JWT_SECRET, signing_input, hashlib.sha256).digest()
        received = b64url_decode(encoded_signature)
        if not hmac.compare_digest(expected, received):
            return None
        payload = json.loads(b64url_decode(encoded_payload))
        if int(payload.get("exp", 0)) < int(time.time()):
            return None
        return payload
    except (ValueError, TypeError, json.JSONDecodeError):
        return None


class Lesson4APIHandler(BaseHTTPRequestHandler):
    server_version = "Lesson4API/1.0"

    def _cors_headers(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header(
            "Access-Control-Allow-Headers",
            "content-type, authorization, x-api-key",
        )
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")

    def _send_json(self, status: int, payload: object) -> None:
        body = json.dumps(payload, separators=(",", ":")).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self._cors_headers()
        self.end_headers()
        self.wfile.write(body)

    def _read_body(self) -> bytes:
        length = int(self.headers.get("Content-Length", "0"))
        return self.rfile.read(length)

    def _read_json(self) -> dict[str, object] | None:
        try:
            value = json.loads(self._read_body() or b"{}")
            return value if isinstance(value, dict) else None
        except json.JSONDecodeError:
            return None

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self._cors_headers()
        self.end_headers()

    def do_GET(self) -> None:
        path = urlparse(self.path).path

        if path == "/health":
            self._send_json(200, {"status": "ok", "service": "lesson4-api"})
            return

        if path == "/openapi.json":
            definition = json.loads((BASE_DIR / "openapi.json").read_text())
            self._send_json(200, definition)
            return

        if path == "/api/profile":
            authorization = self.headers.get("Authorization", "")
            if not authorization.startswith("Bearer "):
                self._send_json(401, {"error": "missing bearer token"})
                return
            claims = verify_token(authorization.removeprefix("Bearer ").strip())
            if claims is None:
                self._send_json(401, {"error": "invalid or expired token"})
                return
            self._send_json(
                200,
                {
                    "username": claims["sub"],
                    "role": claims["role"],
                    "claims": claims,
                },
            )
            return

        if path.startswith("/api/users/"):
            user_id = path.removeprefix("/api/users/")
            if user_id.isdigit():
                self._send_json(
                    200,
                    {"id": int(user_id), "username": f"user{user_id}"},
                )
            else:
                self._send_json(400, {"error": "id must be numeric"})
            return

        self._send_json(404, {"error": "not found", "path": path})

    def do_POST(self) -> None:
        path = urlparse(self.path).path

        if path == "/api/register":
            data = self._read_json()
            if data is None:
                self._send_json(400, {"error": "invalid JSON"})
                return
            self._send_json(201, {"status": "registered", "received": data})
            return

        if path == "/api/login":
            data = self._read_json()
            if data == {"username": "kady", "password": "Pass123!"}:
                self._send_json(200, {"token": issue_token("kady")})
            else:
                self._send_json(401, {"error": "invalid credentials"})
            return

        if path == "/api/xml/upload":
            body = self._read_body()
            self._send_json(
                200,
                {
                    "status": "xml received",
                    "bytes": len(body),
                    "preview": body[:200].decode("utf-8", errors="replace"),
                },
            )
            return

        if path == "/graphql":
            data = self._read_json()
            if data is None or "query" not in data:
                self._send_json(400, {"errors": [{"message": "query is required"}]})
                return
            self._send_json(
                200,
                {
                    "data": {"user": {"id": 1, "username": "kady"}},
                    "queryEcho": data["query"],
                },
            )
            return

        self._send_json(404, {"error": "not found", "path": path})


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), Lesson4APIHandler)
    print(f"Serving Lesson 4 API on {HOST}:{PORT}")
    server.serve_forever()

