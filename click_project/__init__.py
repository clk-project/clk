#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

# keep it at the begin in order to get an accurate startup time
from datetime import datetime
startup_time = datetime.now()

from click_project import monkeypatch  # NOQA: E402
from click_project import log  # NOQA: E402
from click_project.overloads import entry_point  # NOQA: E402

__version__ = '0.1'

monkeypatch.do()

LOGGER = log.get_logger(__name__)
log.basic_config(LOGGER)
LOGGERS = {LOGGER}
