#!/usr/bin/env bash
set -euo pipefail

DATETIME_TZ=$(date '+%Y-%m-%d %H:%M:%S %Z')
FILENAME_TS=$(date '+%Y-%m-%d_%H-%M-%S')

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)
  GIT_COMMIT=$(git rev-parse HEAD)
else
  REPO_NAME=""
  GIT_BRANCH=""
  GIT_COMMIT=""
fi

THOUGHTS_DIR="$(pwd)/thoughts"
THOUGHTS_STATUS=""
if [ -d "$THOUGHTS_DIR" ] && git -C "$THOUGHTS_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  T_BRANCH=$(git -C "$THOUGHTS_DIR" branch --show-current 2>/dev/null || echo "unknown")
  T_CHANGES=$(git -C "$THOUGHTS_DIR" status --short 2>/dev/null)
  THOUGHTS_STATUS="Thoughts Branch: $T_BRANCH"
  if [ -n "$T_CHANGES" ]; then
    THOUGHTS_STATUS="$THOUGHTS_STATUS
Thoughts Changes:
$T_CHANGES"
  fi
fi

echo "Current Date/Time (TZ): $DATETIME_TZ"
[ -n "$GIT_COMMIT" ] && echo "Current Git Commit Hash: $GIT_COMMIT"
[ -n "$GIT_BRANCH" ] && echo "Current Branch Name: $GIT_BRANCH"
[ -n "$REPO_NAME" ] && echo "Repository Name: $REPO_NAME"
echo "Timestamp For Filename: $FILENAME_TS"
[ -n "$THOUGHTS_STATUS" ] && echo "$THOUGHTS_STATUS"
