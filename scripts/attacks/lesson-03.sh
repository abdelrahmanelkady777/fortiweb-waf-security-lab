#!/usr/bin/env bash
set -u

juice="${JUICE_URL:-http://juice.lab.local}"
urlenc="${URLENC_URL:-http://urlenc.lab.local}"

echo "Authorized isolated-lab tests only."

run() {
  local name="$1"
  shift
  echo
  echo "== $name =="
  curl -sS -o /dev/null -w 'HTTP %{http_code}\n' "$@"
}

run "XSS literal" "$juice/rest/products/search?q=<script>alert(1)</script>"
run "XSS encoded" "$juice/rest/products/search?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E"
run "Path traversal" "$juice/rest/products/search?q=../../../../etc/passwd"
run "SQL injection" "$juice/rest/products/search?q=' OR '1'='1--"
run "Evil CORS origin" -H "Origin: http://evil.example" \
  "$juice/rest/products/search?q=apple"
run "Allowed CORS origin" -H "Origin: http://juice.lab.local" \
  "$juice/rest/products/search?q=apple"
run "DLP response" "$urlenc/public/dlp.html"

echo "normal text file" > /tmp/fortiweb-good.txt
echo "harmless content with a PHP extension" > /tmp/fortiweb-shell.php
run "Allowed text upload" -F "file=@/tmp/fortiweb-good.txt;filename=good.txt" \
  "$urlenc/upload"
run "Blocked extension upload" -F "file=@/tmp/fortiweb-shell.php;filename=shell.php" \
  "$urlenc/upload"

