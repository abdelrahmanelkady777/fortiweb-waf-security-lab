#!/usr/bin/env bash
set -u

test_url() {
  local name="$1"
  local url="$2"
  local status
  status=$(curl -k -s -o /dev/null -w '%{http_code}' "$url")
  printf '%-28s %s\n' "$name" "$status"
}

echo "FortiWeb lab regression smoke test"
test_url "Juice Shop HTTP" "http://juice.lab.local/"
test_url "Juice Shop HTTPS" "https://juice.lab.local/"
test_url "WebGoat HTTP" "http://webgoat.lab.local/WebGoat/"
test_url "Lesson 3 test site" "http://urlenc.lab.local/public/lwjs.html"
test_url "Lesson 4 API health" "http://api.lab.local/health"
test_url "Lesson 6 delivery" "http://delivery.lab.local/"
test_url "Lesson 6 reports" "http://reports.lab.local/"
test_url "Lesson 6 redirect source" "http://delivery.lab.local/old"
test_url "Lesson 7 fast DoS target" "http://delivery.lab.local/new"
