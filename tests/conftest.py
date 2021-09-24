#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import tempfile
from pathlib import Path
from shlex import split
from subprocess import check_call, check_output

import pytest


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
    Lib.run('direnv allow')
    yield root
    del os.environ['CLKCONFIGDIR']
    os.chdir(prev)


@pytest.fixture()
def pythondir(root_dir):
    res = Path(root_dir) / 'clk' / 'python'
    if not res.exists():
        os.makedirs(res)
    return res


@pytest.fixture()
def bindir(root_dir):
    res = Path(root_dir) / 'clk' / 'bin'
    if not res.exists():
        os.makedirs(res)
    return res


class Lib:
    @staticmethod
    def run(cmd, *args, **kwargs):
        return check_call(split(cmd), *args, **kwargs)

    @staticmethod
    def out(cmd, *args, **kwargs):
        return check_output(split(cmd), *args, encoding='utf-8', **kwargs).strip()

    @staticmethod
    def cmd(remaining, *args, **kwargs):
        return Lib.out('clk ' + remaining, *args, **kwargs)


@pytest.fixture
def lib():
    return Lib
