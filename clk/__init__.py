#!/usr/bin/env python

# ruff: noqa: E402

import time

# keep it at the begin in order to get an accurate startup time
startup_time = time.time()

import os
import sys


def _force_deps():
    # put the PYTHONPATH entries after the clk installation ones, so that clk
    # uses its own dependencies (click...). Must run before click is imported.
    pythonpath = os.environ.get("PYTHONPATH")
    if not pythonpath:
        return
    pythonpath_entries = {
        os.path.abspath(entry) for entry in pythonpath.split(os.pathsep) if entry
    }
    demoted = [
        entry
        for entry in sys.path
        if entry and os.path.abspath(entry) in pythonpath_entries
    ]
    kept = [entry for entry in sys.path if entry not in demoted]
    sys.path[:] = kept + demoted


if os.environ.get("CLK_FORCE_DEPS") is not None:
    _force_deps()

from clk import log
from clk._version import __version__  # NOQA: F401
from clk.config import config  # NOQA: F401
from clk.core import run  # NOQA: F401
from clk.decorators import (  # NOQA: F401
    argument,
    command,
    flag,
    group,
    option,
    table_fields,
    table_format,  # NOQA: F401
    use_settings,
)
from clk.lib import (  # NOQA: F401
    TablePrinter,
    call,
    check_output,
    copy,
    get_secret,
    makedirs,
    rm,
)
from clk.log import get_logger  # NOQA: F401
from clk.overloads import invoke_hook  # NOQA: F401

LOGGER = log.get_logger(__name__)
log.basic_config(LOGGER)
LOGGERS = {LOGGER}
