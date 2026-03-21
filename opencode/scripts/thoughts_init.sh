#!/usr/bin/env bash
set -euo pipefail

THOUGHTS_DIR="$(pwd)/thoughts"
REPO_URL="${1:-}"

if [ -d "$THOUGHTS_DIR" ]; then
  echo "Error: thoughts/ already exists. Delete it first to reinitialize." >&2
  exit 1
fi

if [ -n "$REPO_URL" ]; then
  git clone "$REPO_URL" "$THOUGHTS_DIR"
  echo "Cloned thoughts repository to $THOUGHTS_DIR"
else
  mkdir -p \
    "$THOUGHTS_DIR/shared/research" \
    "$THOUGHTS_DIR/shared/plans" \
    "$THOUGHTS_DIR/shared/tickets" \
    "$THOUGHTS_DIR/shared/prs" \
    "$THOUGHTS_DIR/shared/handoffs"
  touch \
    "$THOUGHTS_DIR/shared/research/.gitkeep" \
    "$THOUGHTS_DIR/shared/plans/.gitkeep" \
    "$THOUGHTS_DIR/shared/tickets/.gitkeep" \
    "$THOUGHTS_DIR/shared/prs/.gitkeep" \
    "$THOUGHTS_DIR/shared/handoffs/.gitkeep"
  git -C "$THOUGHTS_DIR" init
  echo "Initialized empty thoughts/ at $THOUGHTS_DIR"
  echo "Add a remote: git -C thoughts remote add origin <url>"
fi
