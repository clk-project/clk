#!/usr/bin/env bash
# Tangle org files without requiring personal Emacs configuration.
# Usage:
#   ./tangle.sh                          # tangle all org files with :tangle directives
#   ./tangle.sh doc/use_cases/foo.org    # tangle a specific file
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/org-deps.sh"

tangle_file() {
    local orgfile="$1"
    echo "Tangling $orgfile..."
    local tangled_list
    tangled_list=$(mktemp)
    emacs --batch --no-init-file \
        -l "$SCRIPT_DIR/tangle.el" \
        --eval "(progn
                  (require 'org)
                  (find-file \"$orgfile\")
                  (let ((files (org-babel-tangle)))
                    (with-temp-file \"$tangled_list\"
                      (dolist (f files)
                        (insert f \"\n\"))))
                  (kill-buffer))" || true
    # Verify tangle produced output
    [ -s "$tangled_list" ] || { echo "Error: tangling $orgfile produced no output" >&2; return 1; }
    # Post-process tangled files to match pre-commit hooks
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        sed -i 's/[[:space:]]*$//' "$f"
        case "$f" in *.py) ruff format --quiet "$f" 2>/dev/null || true ;; esac
    done < "$tangled_list"
    rm -f "$tangled_list"
}

if [ $# -eq 0 ]; then
    # Tangle all org files that have :tangle directives
    for f in "$SCRIPT_DIR"/doc/use_cases/*.org \
             "$SCRIPT_DIR"/clk/lib.org \
             "$SCRIPT_DIR"/README.org; do
        [ -f "$f" ] && grep -q ':tangle' "$f" && tangle_file "$f" || true
    done
else
    for f in "$@"; do
        tangle_file "$(realpath "$f")"
    done
fi
