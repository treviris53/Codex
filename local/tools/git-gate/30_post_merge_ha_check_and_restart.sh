#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

YES=0
if [[ "${1:-}" == "--yes" ]]; then
  YES=1
fi

if ! command -v ha >/dev/null 2>&1; then
  echo "ERROR: 'ha' CLI not found. Run this on the HAOS host (SSH/Terminal Add-on) where 'ha' is available." >&2
  exit 1
fi

echo "Running: ha core check"
ha core check

echo "OK: core check passed."

if [[ "$YES" -eq 1 ]]; then
  echo "Restarting Home Assistant Core..."
  ha core restart
  echo "OK: restart triggered."
  exit 0
fi

echo
read -r -p "Restart Home Assistant Core now? (y/N) " ans || true
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
  ha core restart
  echo "OK: restart triggered."
else
  echo "Skipped restart."
fi
