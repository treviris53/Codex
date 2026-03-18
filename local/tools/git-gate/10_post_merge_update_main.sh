#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

REPO_DIR="${REPO_DIR:-/config}"
REMOTE="${REMOTE:-origin}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

cd "$REPO_DIR"

if [ ! -d ".git" ]; then
  echo "ERROR: Not a git repository: $REPO_DIR" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: Working tree is not clean. Commit/stash first." >&2
  git status --porcelain >&2
  exit 1
fi

echo "Fetching..."
git fetch "$REMOTE" --prune

echo "Switching to $MAIN_BRANCH..."
git switch "$MAIN_BRANCH" >/dev/null 2>&1 || {
  echo "ERROR: Branch '$MAIN_BRANCH' not found locally." >&2
  exit 1
}

echo "Fast-forward pull on $MAIN_BRANCH..."
git pull --ff-only "$REMOTE" "$MAIN_BRANCH"

echo "OK: $MAIN_BRANCH updated."
git --no-pager log -1 --oneline --decorate
