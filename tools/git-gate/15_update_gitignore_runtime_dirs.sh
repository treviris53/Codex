#!/usr/bin/env bash
# Version: 1.0.0
# Purpose: Maintain a managed .gitignore block for HA runtime/integration dirs (only if present),
#          without touching user-defined rules outside the block.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)" >/dev/null

BEGIN_MARK="# BEGIN HA GIT-GATE (managed)"
END_MARK="# END HA GIT-GATE (managed)"

# Normalize .gitignore line endings to LF (no staging here)
if [[ -f .gitignore ]] && grep -q $'\r' .gitignore 2>/dev/null; then
  tmp="$(mktemp)"
  tr -d '\r' < .gitignore > "$tmp" && mv "$tmp" .gitignore
fi
# Remove BOM if present
if [[ -f .gitignore ]]; then
  sed -i '1s/^\xEF\xBB\xBF//' .gitignore
fi

# Safe candidates: only add if the dir exists in /config
CANDIDATE_DIRS=(
  "custom_components"
  "templates"
  "www"
  "esphome"
  "homematicip_local"
  "zigbee2mqtt"
  "local"
  "tts"
  "backups"
  "share"
  "deps"
  "health_snapshots"
)

RUNTIME_FILES=(
  ".ha_run.lock"
  "home-assistant.log.fault"
  "home-assistant.log*"
  "home-assistant_v2.db*"
  "*.log"
)

# Build managed block
block="$(mktemp)"
{
  echo "$BEGIN_MARK"
  echo "# Managed by tools/git-gate/15_update_gitignore_runtime_dirs.sh"
  echo "# Runtime/integration-generated directories (only if present):"
  for d in "${CANDIDATE_DIRS[@]}"; do
    [[ -d "$d" ]] && echo "$d/"
  done
  echo ""
  echo "# Runtime artifacts:"
  for f in "${RUNTIME_FILES[@]}"; do
    echo "$f"
  done
  echo "$END_MARK"
} > "$block"

# If .gitignore does not exist, create it
touch .gitignore

# Remove old block if present
tmp="$(mktemp)"
awk -v begin="$BEGIN_MARK" -v end="$END_MARK" '
  $0==begin {inblock=1; next}
  $0==end {inblock=0; next}
  !inblock {print}
' .gitignore > "$tmp" && mv "$tmp" .gitignore

# Ensure file ends with a newline
printf '\n' >> .gitignore

# Append new block at end
cat "$block" >> .gitignore
rm -f "$block"

echo "OK: updated managed .gitignore block."

