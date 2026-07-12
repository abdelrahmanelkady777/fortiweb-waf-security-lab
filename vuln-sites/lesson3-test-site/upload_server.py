"""Deterministic HTTP backend for FortiWeb Lesson 3 tests."""

from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class Handler(SimpleHTTPRequestHandler):
    def do_POST(self) -> None:
        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length)
        print(f"[POST] Path: {self.path}")
        print(f"[POST] Content-Type: {self.headers.get('Content-Type')}")
        print(f"[POST] Bytes received: {len(body)}")

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"POST received by backend\n")


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 8000), Handler)
    print("Serving Lesson 3 test site on 0.0.0.0:8000")
    server.serve_forever()

