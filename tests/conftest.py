#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import tempfile
from pathlib import Path

import pytest


@pytest.fixture(autouse=True)
def move_somewhere():
    root = tempfile.mkdtemp()
    prev = os.getcwd()
    os.chdir(root)
    os.environ['CLKCONFIGDIR'] = str(Path(root) / 'clk')
    yield
    del os.environ['CLKCONFIGDIR']
    os.chdir(prev)
