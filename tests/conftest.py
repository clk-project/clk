#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import tempfile
from pathlib import Path

import pytest
from lib import run


@pytest.fixture()
def project():
    root = tempfile.mkdtemp(dir=os.getcwd())
    os.makedirs(Path(root) / '.clk')
    return root


project1 = project


@pytest.fixture(autouse=True)
def root_dir(request):
    root = tempfile.mkdtemp(prefix=request.node.name[len('test_'):] + '_')
    prev = os.getcwd()
    os.chdir(root)
    os.environ['CLKCONFIGDIR'] = str(Path(root) / 'clk')
    (Path(root) / '.envrc').write_text(f"export CLKCONFIGDIR={os.environ['CLKCONFIGDIR']}")
    run('direnv allow')
    yield root
    del os.environ['CLKCONFIGDIR']
    os.chdir(prev)


@pytest.fixture()
def pythondir(root_dir):
    res = Path(root_dir) / 'clk' / 'python'
    if not res.exists():
        os.makedirs(res)
    return res
