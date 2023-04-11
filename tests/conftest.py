#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import tempfile
from pathlib import Path
from shlex import split
from shutil import copytree, rmtree
from subprocess import STDOUT, check_call, check_output

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
    os.environ['CLK_TEST_ROOT'] = str(Path(root))
    os.environ['CURRENT_CLK'] = str(Path(__file__).parent.parent)
    os.environ['CLKCONFIGDIR'] = str(Path(root) / 'clk-root')
    print(root)
    (Path(root) / '.envrc').write_text('export CLKCONFIGDIR="$(pwd)/clk-root"')
    Lib.run('direnv allow')
    yield root
    del os.environ['CLKCONFIGDIR']
    del os.environ['CLK_TEST_ROOT']
    del os.environ['CURRENT_CLK']
    os.chdir(prev)


@pytest.fixture()
def pythondir():
    res = Path(os.environ['CLKCONFIGDIR']) / 'python'
    if not res.exists():
        os.makedirs(res)
    return res


@pytest.fixture()
def bindir():
    res = Path(os.environ['CLKCONFIGDIR']) / 'bin'
    if not res.exists():
        os.makedirs(res)
    return res


class Lib:
    first_call = True

    def __init__(self, bindir):
        self.bindir = bindir

    def assert_intrusive(self):
        assert os.environ.get('CLK_ALLOW_INTRUSIVE_TEST') == 'True', 'Intrusive test'

    @staticmethod
    def run(cmd, *args, **kwargs):
        return check_call(split(cmd), *args, **kwargs)

    @staticmethod
    def out(cmd, with_err=False, *args, **kwargs):
        if with_err:
            kwargs['stderr'] = STDOUT
        return check_output(split(cmd), *args, encoding='utf-8', **kwargs).strip()

    def cmd(self, remaining, *args, **kwargs):
        command = ('python3 -u -m coverage run'
                   ' --source clk'
                   ' -m clk ' + remaining)
        try:
            res = self.out(command, *args, **kwargs)
        finally:
            old_dir = os.getcwd()
            current_coverage_location = (Path(os.getcwd()) / '.coverage').resolve()
            coverage_location = (Path(__file__).parent).resolve()
            assert current_coverage_location != coverage_location
            combine_command = 'coverage combine '
            if Lib.first_call:
                Lib.first_call = False
            else:
                combine_command += ' --append '
            combine_command += str(current_coverage_location)
            os.chdir(Path(__file__).parent)
            self.run(combine_command)
            os.chdir(old_dir)
        return res

    def create_bash_command(self, name, content):
        path = self.bindir / name
        path.write_text(content)
        path.chmod(0o755)

    def use_config(self, name):
        rootdir = Path(os.environ['CLKCONFIGDIR'])
        if rootdir.exists():
            rmtree(rootdir)
        copytree(Path(__file__).parent / 'profiles' / name, rootdir)

    def use_project(self, name):
        rootdir = Path(os.environ['CLKCONFIGDIR'])
        project_dir = rootdir.parent / '.clk'
        if project_dir.exists():
            rmtree(project_dir)
        copytree(Path(__file__).parent / 'profiles' / name, project_dir)


@pytest.fixture
def lib(bindir):
    return Lib(bindir)
