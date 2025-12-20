#!/usr/bin/env python
# [[id:919c606c-d455-403e-a201-b5c506420b64][weave:1]]
# GENERATED USING lib.org, DO NOT EDIT

import os
import shutil

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
        if not (os.path.exists(f) or os.path.islink(f)):
            LOGGER.debug(f"{f} not removed because already missing")
            return
        if os.path.isdir(f) and not os.path.islink(f):
            shutil.rmtree(f)
        else:
            os.unlink(f)


# end
# weave:1 ends here
