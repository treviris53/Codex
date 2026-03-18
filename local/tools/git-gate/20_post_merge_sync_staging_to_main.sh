#!/usr/bin/env bash
# Version: 1.0.0
set -euo pipefail

REPO_DIR="${REPO_DIR:-/config}"
REMOTE="${REMOTE:-origin}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"
STAGING_BRANCH="${STAGING_BRANCH:-staging}"

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

# Ensure remote main exists
git show-ref --verify --quiet "refs/remotes/$REMOTE/$MAIN_BRANCH" || {
  echo "ERROR: Remote branch not found: $REMOTE/$MAIN_BRANCH" >&2
  exit 1
}

# Ensure local staging exists (create tracking if missing)
if ! git show-ref --verify --quiet "refs/heads/$STAGING_BRANCH"; then
  echo "Creating local branch '$STAGING_BRANCH' tracking '$REMOTE/$STAGING_BRANCH' (or '$REMOTE/$MAIN_BRANCH' if missing)..."
  if git show-ref --verify --quiet "refs/remotes/$REMOTE/$STAGING_BRANCH"; then
    git switch -c "$STAGING_BRANCH" --track "$REMOTE/$STAGING_BRANCH"
  else
    git switch -c "$STAGING_BRANCH" --track "$REMOTE/$MAIN_BRANCH"
  fi
else
  git switch "$STAGING_BRANCH"
fi

echo "Resetting $STAGING_BRANCH to $REMOTE/$MAIN_BRANCH..."
git reset --hard "$REMOTE/$MAIN_BRANCH"

echo "Pushing $STAGING_BRANCH with --force-with-lease (safe force)..."
git push --force-with-lease "$REMOTE" "$STAGING_BRANCH"

echo "OK: $STAGING_BRANCH is now aligned with $REMOTE/$MAIN_BRANCH."
git --no-pager log -1 --oneline --decorate
