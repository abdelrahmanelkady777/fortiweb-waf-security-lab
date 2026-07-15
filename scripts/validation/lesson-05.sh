#!/usr/bin/env bash
set -euo pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"
host="${LESSON5_HOST:-bot.lab.local}"

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1" >&2; exit 1; }

if [[ ! "$vip" =~ ^10\. && ! "$vip" =~ ^192\.168\. && ! "$vip" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. && ! "$vip" =~ ^127\. ]]; then
  fail "Refusing a non-private FortiWeb VIP: $vip"
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
request=(curl --silent --show-error --connect-timeout 5 --max-time 20 --resolve "$host:80:$vip")

expect_status() {
  local expected="$1" path="$2" label="$3" actual
  actual=$("${request[@]}" -o /dev/null -w '%{http_code}' "http://$host$path")
  [[ "$actual" == "$expected" ]] && pass "$label returned $expected" || fail "$label returned $actual; expected $expected"
}

echo "FortiWeb Lesson 5 safe routing and regression validation"
echo "VIP: $vip"
expect_status 200 /health "Bot backend health route"
expect_status 200 / "Interactive-page route"
expect_status 200 /products "Product catalogue route"

"${request[@]}" -c "$tmp_dir/cookies" -D "$tmp_dir/root.headers" -o /dev/null "http://$host/"
grep -Eiq '^Set-Cookie:[[:space:]]*cookiesession1=' "$tmp_dir/root.headers" && pass "FortiWeb session cookie is present" || fail "cookiesession1 was not present"

valid_status=$("${request[@]}" -o "$tmp_dir/valid.json" -w '%{http_code}' -X POST "http://$host/login" -H 'Content-Type: application/json' --data '{"username":"demo","password":"FortiWeb123!"}')
[[ "$valid_status" == 200 ]] && grep -q '"authenticated"' "$tmp_dir/valid.json" && pass "Valid lab login is routed and accepted" || fail "Valid lab login did not return the expected 200 response"

invalid_status=$("${request[@]}" -o "$tmp_dir/invalid.json" -w '%{http_code}' -X POST "http://$host/login" -H 'Content-Type: application/json' --data '{"username":"bad","password":"bad"}')
[[ "$invalid_status" == 401 ]] && grep -q '"denied"' "$tmp_dir/invalid.json" && pass "Invalid lab login keeps the backend 401 baseline" || fail "Invalid lab login did not return the expected 401 response"

"${request[@]}" -b "$tmp_dir/cookies" -o "$tmp_dir/headers.json" "http://$host/headers"
grep -q '"x_forwarded_for"' "$tmp_dir/headers.json" && pass "Backend header-observation route is available" || fail "Header-observation response is incomplete"

echo
echo "Manual FortiWeb evidence still required:"
echo "  - interactive-browser/curl biometric and temporary enforcement proof"
echo "  - threshold events and recovery after block period"
echo "  - Wget, Nikto, spoofed-crawler, and ML model/anomaly/final-state evidence"
