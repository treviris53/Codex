#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

CONFIG_DIR="${CONFIG_DIR:-/config}"
Z2M_DIR="${Z2M_DIR:-$CONFIG_DIR/zigbee2mqtt}"
Z2M_CFG="${Z2M_CFG:-$Z2M_DIR/configuration.yaml}"

LOCAL_BASE="${LOCAL_BASE:-$CONFIG_DIR/local/z2m}"
GOLDEN_CFG="${GOLDEN_CFG:-$LOCAL_BASE/configuration.golden.yaml}"
LOG_FILE="${LOG_FILE:-$LOCAL_BASE/guard.log}"
BACKUP_DIR="${BACKUP_DIR:-$LOCAL_BASE/backups}"

NO_RESTART=0
FORCE=0
INIT=0
UPDATE_GOLDEN=0
DRY_RUN=0

mkdir -p "$LOCAL_BASE" "$BACKUP_DIR"

log() {
  local msg="$1"
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$msg" | tee -a "$LOG_FILE" >/dev/null
}

die() {
  log "ERROR: $1"
  exit 1
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

detect_z2m_slug() {
  if ! command -v ha >/dev/null 2>&1; then
    echo ""
    return 0
  fi
  # output format varies; this is a robust heuristic: first column of the line containing "zigbee2mqtt"
  ha addons list 2>/dev/null | awk 'tolower($0) ~ /zigbee2mqtt/ {print $1; exit}'
}

restart_z2m_addon() {
  local slug="$1"
  if [ -z "$slug" ]; then
    log "Z2M addon slug not found (skipping restart)."
    return 0
  fi
  if ! command -v ha >/dev/null 2>&1; then
    log "ha CLI not available (skipping restart)."
    return 0
  fi

  log "Restarting Zigbee2MQTT addon: $slug"
  ha addons restart "$slug" >/dev/null 2>&1 || log "WARN: failed to restart addon $slug"
}

# Heuristics: detect "likely overwritten / onboarding / minimal config"
is_suspicious_config() {
  local f="$1"

  # Typical onboarding / minimal config patterns
  if grep -qiE '^\s*onboarding:\s*true\s*$' "$f"; then
    return 0
  fi
  if grep -qiE '^\s*serial:\s*\{\s*\}\s*$' "$f"; then
    return 0
  fi

  # Missing serial.port is a strong sign of an unintended overwrite in established installs
  # We accept both "serial: / port:" (indented) and a direct "serial:" block
  if ! grep -qiE '^\s*serial:\s*$' "$f"; then
    return 0
  fi
  if ! grep -qiE '^\s*port:\s*.+$' "$f"; then
    return 0
  fi

  # If file is extremely small, it is suspicious (common after UI resets)
  local bytes
  bytes="$(wc -c < "$f" | tr -d ' ')"
  if [ "$bytes" -lt 120 ]; then
    return 0
  fi

  return 1
}

usage() {
  cat <<'EOF'
Zigbee2MQTT config guard

Usage:
  60_z2m_config_guard.sh --init
  60_z2m_config_guard.sh [--no-restart] [--force] [--dry-run]
  60_z2m_config_guard.sh --update-golden

Options:
  --init           Create golden config from current /config/zigbee2mqtt/configuration.yaml (only if not existing)
  --update-golden  Overwrite golden config with current config (intentional changes)
  --force          Restore golden even if heuristics do not flag config as suspicious
  --no-restart     Do not restart Zigbee2MQTT add-on after restore
  --dry-run        Show what would happen, but do not copy/restart
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --init) INIT=1 ;;
    --update-golden) UPDATE_GOLDEN=1 ;;
    --force) FORCE=1 ;;
    --no-restart) NO_RESTART=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
  shift
done

[ -f "$Z2M_CFG" ] || die "Z2M config not found: $Z2M_CFG"

# Ensure CRLF cannot break scripts/config comparisons
# (does not modify the Z2M config by default—only used for script robustness)
if grep -q $'\r' "$Z2M_CFG" 2>/dev/null; then
  log "WARN: CRLF detected in $Z2M_CFG (Z2M may still parse it, but it is unusual)."
fi

if [ "$UPDATE_GOLDEN" -eq 1 ]; then
  log "Updating golden config: $GOLDEN_CFG (from $Z2M_CFG)"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY RUN: would copy current config to golden."
    exit 0
  fi
  cp -f "$Z2M_CFG" "$GOLDEN_CFG"
  log "OK: golden updated."
  exit 0
fi

if [ "$INIT" -eq 1 ]; then
  if [ -f "$GOLDEN_CFG" ]; then
    log "Golden already exists: $GOLDEN_CFG (no changes)"
    exit 0
  fi
  log "Initializing golden config: $GOLDEN_CFG (from $Z2M_CFG)"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY RUN: would create golden."
    exit 0
  fi
  cp -f "$Z2M_CFG" "$GOLDEN_CFG"
  log "OK: golden created."
  exit 0
fi

[ -f "$GOLDEN_CFG" ] || die "Golden config missing. Run with --init first: $GOLDEN_CFG"

current_hash="$(hash_file "$Z2M_CFG")"
golden_hash="$(hash_file "$GOLDEN_CFG")"

if [ "$current_hash" = "$golden_hash" ]; then
  log "OK: Z2M config matches golden (hash=$current_hash)."
  exit 0
fi

log "WARN: Z2M config differs from golden."
log "  current: $current_hash"
log "  golden : $golden_hash"

suspicious=0
if is_suspicious_config "$Z2M_CFG"; then
  suspicious=1
  log "WARN: Current Z2M config looks suspicious (likely overwritten/onboarding/minimal)."
else
  log "INFO: Current Z2M config does not match golden but is not flagged as suspicious."
fi

if [ "$FORCE" -eq 0 ] && [ "$suspicious" -eq 0 ]; then
  log "INFO: Not restoring (use --force to enforce golden)."
  exit 0
fi

ts="$(date '+%Y%m%d_%H%M%S')"
backup_path="$BACKUP_DIR/configuration.yaml.${ts}.bak"

log "Restoring golden config to $Z2M_CFG (backup first: $backup_path)"

if [ "$DRY_RUN" -eq 1 ]; then
  log "DRY RUN: would backup current and restore golden; would restart addon unless --no-restart."
  exit 0
fi

cp -f "$Z2M_CFG" "$backup_path"
cp -f "$GOLDEN_CFG" "$Z2M_CFG"

# Preserve sensible perms; leave ownership as is
chmod 0644 "$Z2M_CFG" 2>/dev/null || true

if [ "$NO_RESTART" -eq 1 ]; then
  log "INFO: --no-restart set, skipping Zigbee2MQTT restart."
  exit 0
fi

slug="$(detect_z2m_slug)"
restart_z2m_addon "$slug"

log "DONE: golden restored and Zigbee2MQTT restart triggered (if available)."
