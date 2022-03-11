#!/usr/bin/env python
# -*- coding: utf-8 -*-

# keep it at the begin in order to get an accurate startup time
from datetime import datetime

startup_time = datetime.now()

from clk import log  # NOQA: E402
from clk import monkeypatch  # NOQA: E402
from clk.config import config  # NOQA: E402, F401
from clk.core import run  # NOQA: E402, F401
from clk.decorators import table_format  # NOQA: E402, F401
from clk.decorators import argument, command, flag, group, option, table_fields, use_settings  # NOQA: E402, F401
from clk.lib import TablePrinter, call, check_output, copy, makedirs, rm  # NOQA: E402, F401
from clk.log import get_logger  # NOQA: E402, F401
from clk.overloads import entry_point  # NOQA: E402, F401

monkeypatch.do()

LOGGER = log.get_logger(__name__)
log.basic_config(LOGGER)
LOGGERS = {LOGGER}
