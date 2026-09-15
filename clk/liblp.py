#!/usr/bin/env python
# [[file:lib.org::#weave][weave:1]]
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


def format_opt(opt):
    """Give the option the name it has on the command line"""
    return f"--{opt.replace('_', '-')}"


def format_options(options, glue=False):
    """Turn a dictionary of options into the list of arguments call expects"""
    cmd = []
    for opt, value in options.items():
        if value is True:
            cmd.append(format_opt(opt))
        elif isinstance(value, (list, tuple)):
            for item in value:
                if glue:
                    cmd.append(f"{format_opt(opt)}={item}")
                else:
                    cmd.extend([format_opt(opt), item])
        elif value:
            if glue:
                cmd.append(f"{format_opt(opt)}={value}")
            else:
                cmd.extend([format_opt(opt), value])
    return cmd


# end
# weave:1 ends here
