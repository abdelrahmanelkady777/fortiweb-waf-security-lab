#!/usr/bin/env bash
set -euo pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"
delivery="${LESSON6_DELIVERY_HOST:-delivery.lab.local}"
reports="${LESSON6_REPORTS_HOST:-reports.lab.local}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

curl_delivery=(
  curl --silent --show-error
  --connect-timeout 5 --max-time 20
  --resolve "$delivery:80:$vip"
)

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

expect_status() {
  local expected="$1"
  local url="$2"
  local label="$3"
  local actual

  actual=$("${curl_delivery[@]}" -o /dev/null -w '%{http_code}' "$url")
  [[ "$actual" == "$expected" ]] \
    && pass "$label returned $expected" \
    || fail "$label returned $actual; expected $expected"
}

echo "FortiWeb Lesson 6 automated validation"
echo "VIP: $vip"

expect_status 200 "http://$delivery/" "Delivery route"

redirect_headers=$("${curl_delivery[@]}" -D - -o /dev/null "http://$delivery/old")
grep -Eq '^HTTP/[^ ]+ 302 ' <<<"$redirect_headers" \
  || fail "Redirect source did not return 302"
grep -Eiq "^Location:[[:space:]]*http://$delivery/new" <<<"$redirect_headers" \
  || fail "Redirect Location did not use the public destination"
pass "FortiWeb generated the /old -> /new redirect"

rewrite_body=$("${curl_delivery[@]}" "http://$delivery/legacy/page")
grep -q 'Modern Backend Page' <<<"$rewrite_body" \
  || fail "Internal rewrite did not return the modern backend page"
pass "Internal request rewrite returned the modern page"

location_headers=$(
  "${curl_delivery[@]}" -D - -o /dev/null \
    "http://$delivery/backend-redirect"
)
grep -Eiq "^Location:[[:space:]]*http://$delivery/new" <<<"$location_headers" \
  || fail "Backend Location header was not rewritten to the public hostname"
if grep -q '10\.0\.20\.2:8003' <<<"$location_headers"; then
  fail "Private backend address remained in the response headers"
fi
pass "Response Location header hides the private backend address"

"${curl_delivery[@]}" -H 'Accept-Encoding: gzip' \
  -D "$tmp_dir/gzip.headers" -o "$tmp_dir/gzip.body" \
  "http://$delivery/static/large.txt"
grep -Eiq '^Content-Encoding:[[:space:]]*gzip' "$tmp_dir/gzip.headers" \
  || fail "Compression response did not advertise gzip"
pass "Gzip response compression is active"

lua_headers=$("${curl_delivery[@]}" -I "http://$delivery/")
grep -Eiq '^X-Lesson6-Lua:[[:space:]]*active' <<<"$lua_headers" \
  || fail "Lua response header is missing"
pass "Lua response header is active on delivery.lab.local"

reports_status=$(
  curl --silent --show-error --connect-timeout 5 --max-time 20 \
    --resolve "$reports:80:$vip" -o /dev/null -w '%{http_code}' \
    "http://$reports/"
)
[[ "$reports_status" == "200" ]] \
  && pass "Reports route returned 200" \
  || fail "Reports route returned $reports_status; expected 200"

echo
echo "Manual checks still required:"
echo "  - valid/invalid LDAP login and public-path regression"
echo "  - cross-host SSO in a fresh browser session"
echo "  - post-expiry cache proof in the backend log"
echo "  - acceleration diff plus browser functionality"
echo "  - two independent Waiting Room browser sessions"
