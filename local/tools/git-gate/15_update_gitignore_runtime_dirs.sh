#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

REPO="$(git rev-parse --show-toplevel 2>/dev/null)"
cd "$REPO"

GITIGNORE=".gitignore"

# Kandidaten: nur wenn als Top-Level-Ordner vorhanden, wird /<dir>/ ergänzt.
CANDIDATE_DIRS=(
  backups
  share
  deps
  media
  ssl
  tmp
)

# Markerblock (damit wir sauber append-only bleiben)
MARKER_BEGIN="# --- Auto-added runtime dirs (local-only) ---"
MARKER_END="# --- End auto-added runtime dirs ---"

# Stelle sicher, dass der Markerblock existiert
if ! grep -qxF "$MARKER_BEGIN" "$GITIGNORE"; then
  {
    echo ""
    echo "$MARKER_BEGIN"
    echo "$MARKER_END"
  } >> "$GITIGNORE"
fi

# In temp schreiben und dann atomar ersetzen
tmp="$(mktemp)"
awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
  $0==begin {inblock=1; print; next}
  $0==end   {inblock=0; print; next}
  !inblock  {print}
' "$GITIGNORE" > "$tmp"

{
  echo "$MARKER_BEGIN"
  for d in "${CANDIDATE_DIRS[@]}"; do
    if [[ -d "$d" ]]; then
      echo "/$d/"
    fi
  done
  echo "$MARKER_END"
} >> "$tmp"

mv "$tmp" "$GITIGNORE"

echo "OK: updated $GITIGNORE with existing runtime dirs."
