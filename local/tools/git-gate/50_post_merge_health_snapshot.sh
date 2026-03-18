#!/usr/bin/env bash
# Version: 1.0.0
# Capture a small, safe health snapshot (system + HA + git) into /config/health_snapshots.
# Usage: 50_post_merge_health_snapshot.sh [label]
# Example: 50_post_merge_health_snapshot.sh pre
set -euo pipefail

REPO_DIR="${REPO_DIR:-/config}"
OUT_BASE="${OUT_BASE:-/config/health_snapshots}"
LABEL="${1:-snapshot}"
TS="$(date +%F_%H%M%S)"
OUT_DIR="$OUT_BASE/${TS}_${LABEL}"

mkdir -p "$OUT_DIR"

# helper: run command and save output, but never fail the whole snapshot if one command fails
run_save() {
  local name="$1"; shift
  {
    echo "# COMMAND: $*"
    echo "# TIME: $(date -Is)"
    echo
    "$@"
  } > "$OUT_DIR/$name" 2>&1 || {
    echo "WARN: command failed: $*" >> "$OUT_DIR/$name"
    return 0
  }
}

# --- Git context ---
if [ -d "$REPO_DIR/.git" ]; then
  (cd "$REPO_DIR" && run_save git_status.txt bash -lc 'git status -sb && echo && git rev-parse HEAD && git log -1 --oneline --decorate')
  (cd "$REPO_DIR" && run_save git_diff_stat.txt bash -lc 'git diff --stat || true')
else
  echo "WARN: $REPO_DIR is not a git repo" > "$OUT_DIR/git_status.txt"
fi

# --- Home Assistant / HAOS context (if ha CLI exists) ---
if command -v ha >/dev/null 2>&1; then
  run_save ha_core_info.txt ha core info
  run_save ha_core_stats.txt ha core stats
  run_save ha_supervisor_info.txt ha supervisor info
  run_save ha_os_info.txt ha os info
  run_save ha_host_info.txt ha host info
  run_save ha_addons_list.txt ha addons list
  # Logs can be large; keep tail limited
  run_save ha_core_logs_tail200.txt bash -lc 'ha core logs --tail 200 || true'
else
  echo "WARN: ha CLI not found" > "$OUT_DIR/ha_core_info.txt"
fi

# --- Filesystem footprint (no secrets) ---
run_save df_h.txt df -h
run_save free_h.txt free -h || true
run_save uptime.txt uptime

echo "OK: Health snapshot written to: $OUT_DIR"
