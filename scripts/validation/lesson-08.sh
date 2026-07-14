#!/usr/bin/env bash
set -euo pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

if [[ ! "$vip" =~ ^10\. && ! "$vip" =~ ^192\.168\. && \
      ! "$vip" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. && \
      ! "$vip" =~ ^127\. ]]; then
  fail "Refusing a non-private FortiWeb VIP: $vip"
fi

check_target() {
  local host="$1"
  local path="$2"
  local label="$3"
  local status

  status=$(curl --silent --show-error --connect-timeout 5 --max-time 20 \
    --resolve "$host:80:$vip" -o /dev/null -w '%{http_code}' \
    "http://$host$path")

  if [[ "$status" =~ ^[23][0-9][0-9]$ ]]; then
    pass "$label is reachable ($status)"
  else
    fail "$label returned $status; expected a 2xx/3xx readiness response"
  fi
}

echo "FortiWeb Lesson 8 pre-scan readiness and regression validation"
echo "VIP: $vip"
echo "This script does not start an active vulnerability scan."
echo

check_target "juice.lab.local" "/" "Juice Shop route"
check_target "webgoat.lab.local" "/WebGoat/" "WebGoat route"
check_target "urlenc.lab.local" "/public/lwjs.html" "Lesson 3 route"
check_target "api.lab.local" "/health" "Lesson 4 API route"
check_target "delivery.lab.local" "/new" "Lesson 6 delivery route"
check_target "reports.lab.local" "/" "Lesson 6 reports route"

echo
echo "Manual FortiWeb evidence still required for a retained scan record:"
echo "  - Feature Visibility enabled for Web Vulnerability Scan"
echo "  - authorized target, profile, template, scope, exclusions, and intensity"
echo "  - manual/scheduled execution time and Scan History final status"
echo "  - findings or clean result with coverage limits"
echo "  - manual validation, remediation/mitigation, regression, and rescan"
