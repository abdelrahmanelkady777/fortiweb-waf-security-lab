#!/usr/bin/env bash
set -euo pipefail

vip="${FORTIWEB_VIP:-10.0.11.100}"
hosts=(
  juice.lab.local
  webgoat.lab.local
  urlenc.lab.local
  api.lab.local
  delivery.lab.local
  reports.lab.local
)
managed_line="$vip ${hosts[*]}"

if grep -Eq '(^|[[:space:]])(juice|webgoat|urlenc|api|delivery|reports)\.lab\.local([[:space:]]|$)' /etc/hosts; then
  echo "A FortiWeb lab hostname already exists in /etc/hosts. Review it manually:"
  grep -E '(juice|webgoat|urlenc|api|delivery|reports)\.lab\.local' /etc/hosts
  echo "The complete integrated mapping should be:"
  echo "$managed_line"
  exit 1
fi

echo "$managed_line" | sudo tee -a /etc/hosts >/dev/null
echo "Added: $managed_line"
