#!/usr/bin/env bash
set -u -o pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"
delivery="${LESSON7_DELIVERY_HOST:-delivery.lab.local}"
api="${LESSON7_API_HOST:-api.lab.local}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

usage() {
  cat <<'EOF'
Authorized isolated-lab tests only.

Usage: lesson-07.sh <test>

Tests:
  fp          12 same-session requests to /new
  hal         12 source-IP requests with varied query values
  malip       8 concurrent /slow requests with one cookie
  malip-nat   4 + 4 concurrent /slow requests with two cookies
  tcp         6 concurrent /slow requests from one source IP
  sensitive   Controlled JSON payload for new masking-log evidence
  fragment    10 fragmented SYN packets; requires ENABLE_FRAGMENT_TEST=1
  all-http    Run fp, hal, malip, malip-nat, tcp, and sensitive
EOF
}

if [[ "$delivery" != *.lab.local || "$api" != *.lab.local ]]; then
  echo "Refusing non-.lab.local targets." >&2
  exit 2
fi

if [[ ! "$vip" =~ ^10\. && ! "$vip" =~ ^192\.168\. && \
      ! "$vip" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. && \
      ! "$vip" =~ ^127\. ]]; then
  echo "Refusing a non-private FortiWeb VIP: $vip" >&2
  exit 2
fi

curl_delivery=(
  curl --silent --show-error --connect-timeout 5 --max-time 20
  --resolve "$delivery:80:$vip"
)

create_cookie() {
  local jar="$1"
  "${curl_delivery[@]}" -c "$jar" -o /dev/null "http://$delivery/new"
}

parallel_gets() {
  local count="$1"
  local url_template="$2"
  local cookie_jar="${3:-}"
  local prefix="${4:-request}"
  local i url
  local -a cookie_args=()

  [[ -n "$cookie_jar" ]] && cookie_args=(-b "$cookie_jar")

  for ((i = 1; i <= count; i++)); do
    url="${url_template//\{n\}/$i}"
    (
      "${curl_delivery[@]}" --http1.1 -H 'Connection: close' \
        "${cookie_args[@]}" -o /dev/null \
        -w "$prefix=$i code=%{http_code} time=%{time_total}s\n" "$url"
    ) &
  done
  wait
}

run_fp() {
  echo "== FP_1: per-session, per-URL request burst =="
  create_cookie "$tmp_dir/fp.cookies"
  parallel_gets 12 "http://$delivery/new" "$tmp_dir/fp.cookies"
}

run_hal() {
  echo "== HAL_7: aggregate source-IP request burst =="
  parallel_gets 12 "http://$delivery/new?request={n}"

  echo "Fresh-cookie check:"
  "${curl_delivery[@]}" -c "$tmp_dir/hal-fresh.cookies" \
    -o /dev/null -w 'fresh code=%{http_code} time=%{time_total}s\n' \
    "http://$delivery/headers"
}

run_malip() {
  echo "== MALIP_7: one session over the connection limit =="
  create_cookie "$tmp_dir/malip.cookies"
  parallel_gets 8 "http://$delivery/slow" "$tmp_dir/malip.cookies"
}

run_malip_nat() {
  echo "== MALIP_7: two logical clients behind one source IP =="
  create_cookie "$tmp_dir/client-a.cookies"
  create_cookie "$tmp_dir/client-b.cookies"
  parallel_gets 4 "http://$delivery/slow" "$tmp_dir/client-a.cookies" clientA &
  local pid_a=$!
  parallel_gets 4 "http://$delivery/slow" "$tmp_dir/client-b.cookies" clientB &
  local pid_b=$!
  wait "$pid_a"
  wait "$pid_b"
}

run_tcp() {
  echo "== TCPFP_7: source-IP fully formed connection test =="
  parallel_gets 6 "http://$delivery/slow"
}

run_sensitive() {
  echo "== sensitive_l7: controlled values for a new packet log =="
  curl --silent --show-error --connect-timeout 5 --max-time 20 \
    --resolve "$api:80:$vip" -D - -o /dev/null \
    -X POST "http://$api/api/login" \
    -H 'Content-Type: application/json' \
    --data '{"username":"kady","password":"Lesson7Secret!","token":"lesson7-fake-token","card":"4111111111111111"}'
}

run_fragment() {
  if [[ "${ENABLE_FRAGMENT_TEST:-0}" != "1" ]]; then
    echo "Set ENABLE_FRAGMENT_TEST=1 to authorize the 10-packet fragment test." >&2
    exit 2
  fi
  command -v hping3 >/dev/null 2>&1 || {
    echo "hping3 is required for the fragment test." >&2
    exit 2
  }

  echo "== Layer 3 Fragment Protection: 10 fragmented SYN packets =="
  sudo hping3 -S -p 80 -d 120 -f -c 10 "$vip"

  echo "Post-test HTTP regression:"
  "${curl_delivery[@]}" -o /dev/null \
    -w 'code=%{http_code} time=%{time_total}s\n' "http://$delivery/new"
}

test_name="${1:-}"
case "$test_name" in
  fp) run_fp ;;
  hal) run_hal ;;
  malip) run_malip ;;
  malip-nat) run_malip_nat ;;
  tcp) run_tcp ;;
  sensitive) run_sensitive ;;
  fragment) run_fragment ;;
  all-http)
    run_fp
    run_hal
    run_malip
    run_malip_nat
    run_tcp
    run_sensitive
    ;;
  *)
    usage
    [[ -n "$test_name" ]] && exit 2
    ;;
esac
