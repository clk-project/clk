#!/usr/bin/env python

# ruff: noqa: E402

from datetime import datetime

# keep it at the begin in order to get an accurate startup time
startup_time = datetime.now()

from clk import (
    log,
    monkeypatch,
)
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
from clk.overloads import entry_point  # NOQA: F401

from . import _version

monkeypatch.do()

LOGGER = log.get_logger(__name__)
log.basic_config(LOGGER)
LOGGERS = {LOGGER}

__version__ = _version.get_versions()["version"]
