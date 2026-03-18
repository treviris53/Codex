#!/usr/bin/env bash
set -euo pipefail

# Prints a compare URL to open a PR from staging -> main.
# Works for https://github.com/... and git@github.com:... remotes.

cd /config
REMOTE="$(git config --get remote.origin.url || true)"
REMOTE="${REMOTE%.git}"
if [[ "$REMOTE" == git@github.com:* ]]; then
  REMOTE="https://github.com/${REMOTE#git@github.com:}"
fi

echo "${REMOTE}/compare/main...staging?expand=1"
