#!/usr/bin/env python
# [[file:lib.org::*weave][weave:1]]
# GENERATED USING lib.org, DO NOT EDIT

import shutil
from pathlib import Path

from clk.log import get_logger

LOGGER = get_logger(__name__)
dry_run = None


def rm(*file_or_tree):
    """
    Removing some files or directories.

    Does nothing in case dry run is set.
    """

    LOGGER.action("remove {}".format(" ".join(map(str, file_or_tree))))
    if dry_run:
        return
    for f in file_or_tree:
        p = Path(f)
        if not (p.exists() or p.is_symlink()):
            LOGGER.debug(f"{f} not removed because already missing")
            return
        if p.is_dir() and not p.is_symlink():
            shutil.rmtree(f)
        else:
            p.unlink()


# end
# weave:1 ends here
