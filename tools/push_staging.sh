#!/usr/bin/env bash
# Version: 1.1.1
# Change note (2026-01-23): Whitelist reduced; treat integration-generated dirs as non-blocking noise.

set -euo pipefail

DEFAULT_MSG="chore: update"
INCLUDE_SECRETS=0

usage() {
  cat <<'EOF'
push_staging.sh - staging-first commit helper (WHITELIST)

Usage:
  /config/tools/push_staging.sh "commit message"
  /config/tools/push_staging.sh --include-secrets "commit message"

Behavior:
  - Ensures branch is 'staging'
  - Fast-forward pull on staging
  - Stages ONLY whitelisted paths
  - Ignores changes in known integration/runtime paths (does NOT fail because of them)
  - Commits and pushes to origin/staging

Flags:
  --include-secrets   Also stage 'secrets.yaml' (off by default; generally NOT recommended).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-secrets) INCLUDE_SECRETS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

MSG="${1:-$DEFAULT_MSG}"

cd /config

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" == "main" ]]; then
  echo "ERROR: You are on 'main'. Switch to 'staging' and push from there." >&2
  exit 1
fi

git switch staging >/dev/null 2>&1 || true
git pull --ff-only

# Only commit what you maintain explicitly
ALLOWED_PATHS=(
  ".github"
  ".editorconfig"
  ".gitignore"
  ".HA_VERSION"
  "configuration.yaml"
  "automations.yaml"
  "scripts.yaml"
  "scenes.yaml"
  "fakesecrets.yaml"
  "packages"
  "blueprints"
  "dashboards"
  "tools"
)

if [[ "$INCLUDE_SECRETS" -eq 1 ]]; then
  ALLOWED_PATHS+=("secrets.yaml")
fi

# Changes under these paths are considered "noise": do not stage AND do not block.
NOISE_PREFIXES=(
  "templates"
  "custom_components"
  "esphome"
  "homematicip_local"
  "zigbee2mqtt"
  "local"
  "tts"
  "www"
)

# Noise files in repo root (typical runtime artifacts)
NOISE_FILES_PREFIXES=(
  "home-assistant.log"
  "home-assistant_v2.db"
  "home-assistant_v2.db-shm"
  "home-assistant_v2.db-wal"
  ".HA_RUN.lock"
)

is_allowed() {
  local p="$1"
  for a in "${ALLOWED_PATHS[@]}"; do
    if [[ "$p" == "$a" || "$p" == "$a/"* ]]; then
      return 0
    fi
  done
  return 1
}

is_noise() {
  local p="$1"

  for n in "${NOISE_PREFIXES[@]}"; do
    if [[ "$p" == "$n" || "$p" == "$n/"* ]]; then
      return 0
    fi
  done

  for f in "${NOISE_FILES_PREFIXES[@]}"; do
    if [[ "$p" == "$f"* ]]; then
      return 0
    fi
  done

  return 1
}

mapfile -t status_lines < <(git status --porcelain)

if [[ "${#status_lines[@]}" -eq 0 ]]; then
  echo "OK: No changes detected. Nothing to commit."
  exit 0
fi

outside_blockers=()
secrets_changed=0

for line in "${status_lines[@]}"; do
  path="${line:3}"

  # Handle rename/copy: "old -> new"
  if [[ "$path" == *" -> "* ]]; then
    path="${path##* -> }"
  fi

  path="${path#"${path%%[![:space:]]*}"}"

  if [[ "$path" == "secrets.yaml" ]]; then
    secrets_changed=1
  fi

  # Allowed changes are fine; noise changes are ignored; everything else blocks.
  if is_allowed "$path"; then
    continue
  fi
  if is_noise "$path"; then
    continue
  fi

  outside_blockers+=("$path")
done

if [[ "$secrets_changed" -eq 1 && "$INCLUDE_SECRETS" -eq 0 ]]; then
  echo "WARN: secrets.yaml has changes, but --include-secrets was not set; it will NOT be committed by this script." >&2
fi

if [[ "${#outside_blockers[@]}" -gt 0 ]]; then
  echo "ERROR: Found changes outside whitelist and outside known noise paths." >&2
  echo "These MUST be handled manually (commit separately or revert):" >&2
  for p in "${outside_blockers[@]}"; do
    echo "  - $p" >&2
  done
  exit 1
fi

echo "Staging WHITELIST paths only..."
git add -- "${ALLOWED_PATHS[@]}"

if git diff --cached --quiet; then
  echo "OK: Nothing staged after applying whitelist. Nothing to commit."
  exit 0
fi

echo "Commit message: $MSG"
git commit -m "$MSG"

echo "Pushing to origin/staging..."
git push -u origin staging

echo "DONE."
echo "Next: /config/tools/ha_pr_link_staging_to_main.sh"
