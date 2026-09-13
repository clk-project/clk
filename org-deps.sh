#!/usr/bin/env bash
# Provide the pinned org-mode and ox-gfm that tangle.sh and export.sh run on.
# Source it, do not execute it: it sets ORG_DIR and GFM_DIR for the caller.
: "${SCRIPT_DIR:?source me from a script that sets SCRIPT_DIR}"

# Pin org-mode version for reproducible output
ORG_PIN="1025e3b49a98f175b124dbccd774918360fe7e11"
ORG_DIR="$SCRIPT_DIR/.tangle-deps/org"
if [ ! -d "$ORG_DIR" ]; then
    echo "Cloning pinned org-mode ($ORG_PIN)..."
    mkdir -p "$SCRIPT_DIR/.tangle-deps"
    git clone --quiet https://git.savannah.gnu.org/git/emacs/org-mode.git "$ORG_DIR"
    git -C "$ORG_DIR" checkout --quiet "$ORG_PIN"
    # Generate org-loaddefs.el and org-version.el (needed for org to load properly)
    emacs --batch --no-init-file \
        --eval "(progn
                  (push \"$ORG_DIR/lisp\" load-path)
                  (require 'autoload)
                  (setq generated-autoload-file \"$ORG_DIR/lisp/org-loaddefs.el\")
                  (update-directory-autoloads \"$ORG_DIR/lisp\"))" 2>/dev/null
    ORG_GIT_VERSION=$(git -C "$ORG_DIR" describe --tags --match "release_*" 2>/dev/null || echo "N/A")
    ORG_RELEASE=$(echo "$ORG_GIT_VERSION" | sed 's/^release_//;s/-.*//')
    (cd "$ORG_DIR/lisp" && emacs --batch --no-init-file \
        --eval "(progn
                  (push \"$ORG_DIR/lisp\" load-path)
                  (load \"$ORG_DIR/mk/org-fixup.el\")
                  (org-make-org-version \"$ORG_RELEASE\"
                                        \"$ORG_GIT_VERSION\"))") 2>/dev/null || true
fi

# Pin ox-gfm, the markdown backend the committed .md files were written with
GFM_PIN="4f774f13d34b3db9ea4ddb0b1edc070b1526ccbb"
GFM_DIR="$SCRIPT_DIR/.tangle-deps/ox-gfm"
if [ ! -d "$GFM_DIR" ]; then
    echo "Cloning pinned ox-gfm ($GFM_PIN)..."
    mkdir -p "$SCRIPT_DIR/.tangle-deps"
    git clone --quiet https://github.com/larstvei/ox-gfm.git "$GFM_DIR"
    git -C "$GFM_DIR" checkout --quiet "$GFM_PIN"
fi
