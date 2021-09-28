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
def rootdir(request):
    tempdir = Path(tempfile.gettempdir()) / 'clk-tests'
    if not tempdir.exists():
        os.makedirs(tempdir)
    root = tempfile.mkdtemp(dir=tempdir, prefix=request.node.name[len('test_'):] + '_')
    prev = os.getcwd()
    os.chdir(root)
    os.environ['CLKCONFIGDIR'] = str(Path(root) / 'clk')
    print(root)
    (Path(root) / '.envrc').write_text(f"export CLKCONFIGDIR={os.environ['CLKCONFIGDIR']}")
    Lib.run('direnv allow')
    yield root
    del os.environ['CLKCONFIGDIR']
    os.chdir(prev)


@pytest.fixture()
def pythondir(rootdir):
    res = Path(rootdir) / 'clk' / 'python'
    if not res.exists():
        os.makedirs(res)
    return res


@pytest.fixture()
def bindir(rootdir):
    res = Path(rootdir) / 'clk' / 'bin'
    if not res.exists():
        os.makedirs(res)
    return res


class Lib:
    def __init__(self, bindir):
        self.bindir = bindir

    @staticmethod
    def run(cmd, *args, **kwargs):
        return check_call(split(cmd), *args, **kwargs)

    @staticmethod
    def out(cmd, *args, **kwargs):
        return check_output(split(cmd), *args, encoding='utf-8', **kwargs).strip()

    @staticmethod
    def cmd(remaining, *args, **kwargs):
        return Lib.out('clk ' + remaining, *args, **kwargs)

    def create_bash_command(self, name, content):
        path = self.bindir / name
        path.write_text(content)
        path.chmod(0o755)


@pytest.fixture
def lib(bindir):
    return Lib(bindir)
