# Lesson 3 Deterministic Test Site

This backend provides predictable HTML, links, response markers, scripts, hidden fields, and upload behavior for FortiWeb Lesson 3 controls.

## Start

```bash
cd lesson3-test-site
python3 upload_server.py
```

The server listens on `0.0.0.0:8000`.

```bash
curl -i http://127.0.0.1:8000/
curl -i http://127.0.0.1:8000/public/lwjs.html
curl -i http://127.0.0.1:8000/public/dlp.html
```

FortiWeb mapping:

```text
urlenc.lab.local -> route_urlenc -> pool_urlenc_test -> 10.0.20.2:8000
```

The server reads upload bodies only to report their size. It does not save or execute uploaded files.

