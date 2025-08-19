#!/usr/bin/env python

# keep it at the begin in order to get an accurate startup time
from datetime import datetime

from . import _version

startup_time = datetime.now()

from clk import (
    log,  # NOQA: E402
    monkeypatch,  # NOQA: E402
)
from clk.config import config  # NOQA: E402, F401
from clk.core import run  # NOQA: E402, F401
from clk.decorators import (  # NOQA: E402, F401
    argument,
    command,
    flag,
    group,
    option,
    table_fields,
    table_format,  # NOQA: E402, F401
    use_settings,
)
from clk.lib import (  # NOQA: E402, F401
    TablePrinter,
    call,
    check_output,
    copy,
    get_secret,
    makedirs,
    rm,
)
from clk.log import get_logger  # NOQA: E402, F401
from clk.overloads import entry_point  # NOQA: E402, F401

monkeypatch.do()

LOGGER = log.get_logger(__name__)
log.basic_config(LOGGER)
LOGGERS = {LOGGER}

__version__ = _version.get_versions()["version"]
