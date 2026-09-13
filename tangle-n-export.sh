#!/usr/bin/env bash
# Tangle then export org files, which is what you generally want after editing one.
# Usage:
#   ./tangle-n-export.sh                          # every org file, each as it asks for
#   ./tangle-n-export.sh doc/use_cases/foo.org    # a specific file
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -eq 0 ]; then
    "$SCRIPT_DIR/tangle.sh"
    "$SCRIPT_DIR/export.sh"
else
    for f in "$@"; do
        if grep -q ':tangle' "$f"; then
            "$SCRIPT_DIR/tangle.sh" "$f"
        fi
        if grep -q '^#+EXPORT_FILE_NAME:' "$f"; then
            "$SCRIPT_DIR/export.sh" "$f"
        fi
    done
fi
