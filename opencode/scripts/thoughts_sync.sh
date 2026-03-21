#!/usr/bin/env bash
set -euo pipefail

THOUGHTS_DIR="$(pwd)/thoughts"
MESSAGE="${1:-sync: $(date '+%Y-%m-%d_%H-%M-%S')}"

if [ ! -d "$THOUGHTS_DIR" ]; then
  echo "Error: thoughts/ directory does not exist." >&2
  exit 1
fi

if ! git -C "$THOUGHTS_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: thoughts/ is not a git repository." >&2
  exit 1
fi

git -C "$THOUGHTS_DIR" add -A

if git -C "$THOUGHTS_DIR" diff --cached --quiet; then
  echo "No changes to sync in thoughts/."
  exit 0
fi

git -C "$THOUGHTS_DIR" commit -m "$MESSAGE"
git -C "$THOUGHTS_DIR" push
echo "Synced thoughts/. Commit: $MESSAGE"
