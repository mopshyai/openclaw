#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_PATH="${1:-$REPO_ROOT/../openclaw-hostinger-bundle.tgz}"

cd "$REPO_ROOT"

tar \
  --exclude='./node_modules' \
  --exclude='./dist' \
  --exclude='./.git' \
  --exclude='./.openclaw' \
  --exclude='./.openclaw-dev' \
  --exclude='./.DS_Store' \
  -czf "$OUTPUT_PATH" \
  .

printf 'Created bundle: %s\n' "$OUTPUT_PATH"
