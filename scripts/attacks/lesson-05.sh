#!/usr/bin/env bash
set -euo pipefail

# Controlled Lesson 5 exercises for the private EVE-NG lab only.
vip="${FORTIWEB_VIP:-10.0.11.100}"
host="${LESSON5_HOST:-bot.lab.local}"
mode="${1:-}"
if [[ ! "$vip" =~ ^10\. && ! "$vip" =~ ^192\.168\. && ! "$vip" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. && ! "$vip" =~ ^127\. ]]; then
  echo "[FAIL] Refusing a non-private FortiWeb VIP: $vip" >&2; exit 1
fi
request=(curl --silent --show-error --connect-timeout 5 --max-time 20 --resolve "$host:80:$vip")

case "$mode" in
  biometric)
    cookies=$(mktemp); trap 'rm -f "$cookies"' EXIT
    "${request[@]}" -i -c "$cookies" -A 'curl-biometric-test/1.0' "http://$host/"
    sleep 12
    "${request[@]}" -i -b "$cookies" -A 'curl-biometric-test/1.0' "http://$host/"
    ;;
  threshold)
    for i in {1..8}; do "${request[@]}" -s -o /dev/null -w "crawler request=$i status=%{http_code}\n" "http://$host/missing/page-$i"; done
    for i in {1..12}; do "${request[@]}" -s -o /dev/null -w "product=$i status=%{http_code}\n" "http://$host/product/$i"; done
    ;;
  known-bots)
    command -v wget >/dev/null || { echo 'wget is required' >&2; exit 1; }
    output=$(mktemp -d); trap 'rm -rf "$output"' EXIT
    wget --recursive --level=2 --no-parent --no-host-directories --directory-prefix="$output" --user-agent='Wget/1.21.4 FortiWeb-Lesson5' --header="Host: $host" "http://$vip/"
    if command -v nikto >/dev/null; then nikto -h "http://$host" -host "$vip"; else "${request[@]}" -i -A 'Nikto/2.5.0' "http://$host/products"; fi
    "${request[@]}" -i -A 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' "http://$host/products"
    ;;
  ml)
    cookies=$(mktemp); trap 'rm -f "$cookies"' EXIT
    paths=(/ /products /product/1 /api/items /product/2 '/search?q=automation' /login)
    for i in $(seq 1 32); do index=$(( (i - 1) % ${#paths[@]} )); path="${paths[$index]}"; "${request[@]}" -b "$cookies" -c "$cookies" -A 'Lesson5-NeutralAutomation/1.0' -o /dev/null -w "request=$i path=$path code=%{http_code} time=%{time_total}s\n" "http://$host$path"; sleep 5; done
    ;;
  *)
    echo 'Usage: bash scripts/attacks/lesson-05.sh <biometric|threshold|known-bots|ml>' >&2
    echo 'Start in Alert; enable Alert & Deny only for the documented short enforcement check.' >&2
    exit 2
    ;;
esac
