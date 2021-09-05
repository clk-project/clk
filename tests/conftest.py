#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import tempfile
from pathlib import Path

import pytest


@pytest.fixture()
def project():
    root = tempfile.mkdtemp(dir=os.getcwd())
    os.makedirs(Path(root) / '.clk')
    return root


project1 = project


@pytest.fixture(autouse=True)
def move_somewhere():
    root = tempfile.mkdtemp()
    prev = os.getcwd()
    os.chdir(root)
    os.environ['CLKCONFIGDIR'] = str(Path(root) / 'clk')
    yield
    del os.environ['CLKCONFIGDIR']
    os.chdir(prev)


@pytest.fixture()
def pythondir():
    res = Path('.') / 'clk' / 'python'
    if not res.exists():
        os.makedirs(res)
    return res
