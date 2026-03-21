#!/usr/bin/env bash
set -euo pipefail

THOUGHTS_DIR="$(pwd)/thoughts"

if [ ! -d "$THOUGHTS_DIR" ]; then
  echo "thoughts/ does not exist."
  exit 0
fi

if ! git -C "$THOUGHTS_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "thoughts/ exists but is not a git repository."
  exit 0
fi

BRANCH=$(git -C "$THOUGHTS_DIR" branch --show-current 2>/dev/null || echo "unknown")
TRACKING=$(git -C "$THOUGHTS_DIR" status -sb 2>/dev/null | head -1)
STATUS=$(git -C "$THOUGHTS_DIR" status --short 2>/dev/null)

echo "Thoughts directory: $THOUGHTS_DIR"
echo "Branch: $BRANCH"
echo "Tracking: $TRACKING"

if [ -n "$STATUS" ]; then
  echo ""
  echo "Uncommitted changes:"
  echo "$STATUS"
else
  echo "No uncommitted changes."
fi
