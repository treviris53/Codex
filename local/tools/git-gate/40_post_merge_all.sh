#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YES_FLAG="${1:-}"

echo "== Post-merge: install hooks =="
bash "$SCRIPT_DIR/00_install_hooks.sh"

echo
echo "== Post-merge: update main (ff-only) =="
bash "$SCRIPT_DIR/10_post_merge_update_main.sh"

echo
echo "== Post-merge: sync staging -> origin/main =="
bash "$SCRIPT_DIR/20_post_merge_sync_staging_to_main.sh"

echo
echo "== Post-merge: HA core check (+ optional restart) =="
if [[ "$YES_FLAG" == "--yes" ]]; then
  bash "$SCRIPT_DIR/30_post_merge_ha_check_and_restart.sh" --yes
else
  bash "$SCRIPT_DIR/30_post_merge_ha_check_and_restart.sh"
fi

echo
echo "DONE."
