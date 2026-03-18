#!/usr/bin/env bash
# Version: 1.3.0
# Installs/updates git hooks from local git-gate templates.

set -euo pipefail

YES=0
REPO_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) YES=1; shift ;;
    --repo) REPO_DIR="${2:-}"; shift 2 ;;
    -h|--help)
      cat <<'USAGE'
Usage:
  00_install_hooks.sh [--yes] [--repo /config]

Installs:
  .git/hooks/pre-push    (from ./hooks/pre-push next to this script)
  .git/hooks/pre-commit  (from ./hooks/pre-commit next to this script)
USAGE
      exit 0
      ;;
    *) shift ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/hooks"

if [[ -z "$REPO_DIR" ]]; then
  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    REPO_DIR="$git_root"
  else
    REPO_DIR="/config"
  fi
fi

HOOK_DIR="$REPO_DIR/.git/hooks"
mkdir -p "$HOOK_DIR"

install_hook() {
  local name="$1"
  local src="$TEMPLATE_DIR/$name"
  local dest="$HOOK_DIR/$name"

  [[ -f "$src" ]] || { echo "ERROR: Hook template missing: $src" >&2; exit 1; }

  if [[ "$YES" -ne 1 ]]; then
    echo "Install/update hook: $dest"
    read -r -p "Proceed? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
  fi

  local tmp
  tmp="$(mktemp)"
  cp -f "$src" "$tmp"
  # Normalize line endings + remove BOM (defensive)
  tr -d '\r' < "$tmp" > "${tmp}.lf" && mv "${tmp}.lf" "$tmp"
  sed -i '1s/^\xEF\xBB\xBF//' "$tmp"
  chmod +x "$tmp"

  install -m 0755 "$tmp" "$dest"
  rm -f "$tmp"

  echo "OK: Installed/updated $name at: $dest"
}

install_hook pre-push
install_hook pre-commit
