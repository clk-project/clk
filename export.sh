#!/usr/bin/env bash
# Export org files to markdown without requiring personal Emacs configuration.
# Usage:
#   ./export.sh                          # export all org files naming a markdown file
#   ./export.sh doc/use_cases/foo.org    # export a specific file
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/org-deps.sh"

export_file() {
    local orgfile="$1"
    echo "Exporting $orgfile..."
    local exported
    exported="$(dirname "$orgfile")/$(sed -n 's/^#+EXPORT_FILE_NAME: *//p' "$orgfile" | head -1)"
    emacs --batch --no-init-file \
        -l "$SCRIPT_DIR/org-setup.el" \
        --eval "(progn
                  (push \"$GFM_DIR\" load-path)
                  (require 'ox-gfm)
                  (find-file \"$orgfile\")
                  (org-gfm-export-to-markdown)
                  (kill-buffer))"
    [ -f "$exported" ] || { echo "Error: exporting $orgfile produced no output" >&2; return 1; }
    # Post-process exported files to match pre-commit hooks
    sed -i 's/[[:space:]]*$//' "$exported"
}

if [ $# -eq 0 ]; then
    # Export all org files that name a markdown file to export to
    for f in "$SCRIPT_DIR"/doc/use_cases/*.org \
             "$SCRIPT_DIR"/clk/lib.org \
             "$SCRIPT_DIR"/README.org; do
        [ -f "$f" ] && grep -q '^#+EXPORT_FILE_NAME:' "$f" && export_file "$f" || true
    done
else
    for f in "$@"; do
        export_file "$(realpath "$f")"
    done
fi
