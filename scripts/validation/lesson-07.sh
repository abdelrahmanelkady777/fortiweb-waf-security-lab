#!/usr/bin/env bash
set -euo pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"
delivery="${LESSON7_DELIVERY_HOST:-delivery.lab.local}"
reports="${LESSON7_REPORTS_HOST:-reports.lab.local}"
api="${LESSON7_API_HOST:-api.lab.local}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

status_for() {
  local host="$1"
  local path="$2"
  curl --silent --show-error --connect-timeout 5 --max-time 20 \
    --resolve "$host:80:$vip" -o /dev/null -w '%{http_code}' \
    "http://$host$path"
}

expect_status() {
  local expected="$1"
  local host="$2"
  local path="$3"
  local label="$4"
  local actual

  actual=$(status_for "$host" "$path")
  [[ "$actual" == "$expected" ]] \
    && pass "$label returned $expected" \
    || fail "$label returned $actual; expected $expected"
}

echo "FortiWeb Lesson 7 safe validation"
echo "VIP: $vip"

expect_status 200 "$delivery" "/new" "Fast DoS target"
expect_status 200 "$delivery" "/headers" "Fresh-session target"
expect_status 200 "$reports" "/" "Lesson 6 reports regression"
expect_status 200 "$api" "/health" "Lesson 4 API regression"

curl --silent --show-error --connect-timeout 5 --max-time 20 \
  --resolve "$delivery:80:$vip" \
  -D "$tmp_dir/new.headers" -o /dev/null "http://$delivery/new"
grep -Eiq '^Set-Cookie:[[:space:]]*cookiesession1=' "$tmp_dir/new.headers" \
  && pass "FortiWeb session cookie is present for session-aware tests" \
  || fail "cookiesession1 was not present on /new"

slow_result=$(
  curl --silent --show-error --connect-timeout 5 --max-time 20 \
    --resolve "$delivery:80:$vip" -o /dev/null \
    -w '%{http_code} %{time_total}' "http://$delivery/slow"
)
read -r slow_status slow_seconds <<<"$slow_result"
[[ "$slow_status" == "200" ]] || fail "/slow returned $slow_status; expected 200"
awk -v seconds="$slow_seconds" 'BEGIN { exit !(seconds >= 2.5) }' \
  && pass "/slow held the connection for at least 2.5 seconds" \
  || fail "/slow completed in ${slow_seconds}s; concurrency target is not behaving as documented"

echo
echo "Manual FortiWeb checks still required:"
echo "  - filter Attack logs for all four Lesson 7 DoS subtypes"
echo "  - verify same-session and source-IP 30-second block/recovery behavior"
echo "  - confirm two cookie jars remain separate under MALIP_7"
echo "  - confirm Layer 3 Fragment Protection and post-test HTTP availability"
echo "  - inspect 10.0.20.2:514/TCP for JSON Event/Attack/Traffic records"
echo "  - generate a new sensitive payload and confirm values are masked"
echo "  - re-test the Lesson 4 /api/login rate limit after selecting POLHTTP7"
