#!/usr/bin/env bash
# Name the headings of the org files, tangle them and export them, in one emacs.
# Usage:
#   ./org-process.sh                          # every org file
#   ./org-process.sh doc/use_cases/foo.org    # a given file
set -eu

# The versions the committed markdown and tangled files were written with
ORG_PIN="1025e3b49a98f175b124dbccd774918360fe7e11"
ORG_URL="https://git.savannah.gnu.org/git/emacs/org-mode.git"
GFM_PIN="4f774f13d34b3db9ea4ddb0b1edc070b1526ccbb"
GFM_URL="https://github.com/larstvei/ox-gfm.git"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Bring a clone to the pinned commit, cloning it the first time round
sync_dep() {
    local dir="$1" url="$2" pin="$3"
    if [ ! -d "$dir" ]; then
        echo "Cloning $url..."
        git clone --quiet "$url" "$dir"
    fi
    if ! git -C "$dir" rev-parse --quiet --verify "$pin^{commit}" > /dev/null; then
        git -C "$dir" fetch --quiet origin
    fi
    if [ "$(git -C "$dir" rev-parse HEAD)" != "$(git -C "$dir" rev-parse "$pin^{commit}")" ]; then
        echo "Checking $(basename "$dir") out at $pin..."
        git -C "$dir" checkout --quiet "$pin"
    fi
}

mkdir -p "$SCRIPT_DIR/.tangle-deps"
sync_dep "$SCRIPT_DIR/.tangle-deps/org" "$ORG_URL" "$ORG_PIN"
sync_dep "$SCRIPT_DIR/.tangle-deps/ox-gfm" "$GFM_URL" "$GFM_PIN"

files=()
if [ $# -eq 0 ]; then
    for f in "$SCRIPT_DIR"/doc/use_cases/*.org \
             "$SCRIPT_DIR"/clk/lib.org \
             "$SCRIPT_DIR"/README.org; do
        if [ -f "$f" ]; then
            files+=("$f")
        fi
    done
else
    for f in "$@"; do
        files+=("$(realpath "$f")")
    done
fi

written="$(mktemp)"
trap 'rm -f "$written"' EXIT

CLK_ORG_WRITTEN="$written" emacs --batch --no-init-file \
    -l "$SCRIPT_DIR/org-process.el" \
    "${files[@]}"

# Leave what was written the way the pre-commit hooks want it
while IFS= read -r f; do
    [ -f "$f" ] || continue
    sed -i 's/[[:space:]]*$//' "$f"
    case "$f" in
        *.py) ruff format --quiet "$f" 2> /dev/null || true ;;
    esac
done < "$written"
