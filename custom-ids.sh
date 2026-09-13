#!/usr/bin/env bash
# Add a CUSTOM_ID to every heading, so that exporting twice keeps the same anchors.
# Usage:
#   ./custom-ids.sh                          # every org file
#   ./custom-ids.sh doc/use_cases/foo.org    # a specific file
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/org-deps.sh"

custom_ids_file() {
    local orgfile="$1"
    echo "Adding custom ids to $orgfile..."
    emacs --batch --no-init-file \
        -l "$SCRIPT_DIR/org-setup.el" \
        --eval "(progn
                  (find-file \"$orgfile\")
                  (clk-add-custom-ids)
                  (save-buffer)
                  (kill-buffer))"
}

if [ $# -eq 0 ]; then
    for f in "$SCRIPT_DIR"/doc/use_cases/*.org \
             "$SCRIPT_DIR"/clk/lib.org \
             "$SCRIPT_DIR"/README.org; do
        [ -f "$f" ] && custom_ids_file "$f"
    done
else
    for f in "$@"; do
        custom_ids_file "$(realpath "$f")"
    done
fi
