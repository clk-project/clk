#!/usr/bin/env python3
import os
import tempfile
from pathlib import Path
from shlex import split
from shutil import copytree, rmtree
from subprocess import STDOUT, check_call, check_output

import pytest

import coverage

# Global coverage instance for per-test coverage tracking
_per_test_cov = None


@pytest.fixture()
def project():
    root = tempfile.mkdtemp(dir=os.getcwd())
    os.makedirs(Path(root) / ".clk")
    return root


project1 = project


def _test_id_from_nodeid(nodeid):
    """Convert pytest nodeid to a safe filename component."""
    return (
        nodeid.replace("/", "_").replace("::", "_").replace("[", "_").replace("]", "_")
    )


def _short_test_name(nodeid):
    """Convert pytest nodeid to a short test name for context."""
    # tests/test_foo.py::test_bar -> foo:bar
    name = nodeid
    if name.startswith("tests/test_"):
        name = name[len("tests/test_") :]
    if ".py::test_" in name:
        parts = name.split(".py::test_")
        return f"{parts[0]}:{parts[1]}"
    if ".py::" in name:
        parts = name.split(".py::")
        return f"{parts[0]}:{parts[1]}"
    return name


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_protocol(item, nextitem):
    """Start per-test coverage before each test."""
    global _per_test_cov

    test_id = _test_id_from_nodeid(item.nodeid)
    context_name = _short_test_name(item.nodeid)
    coverage_file = Path(__file__).parent / f".coverage.pytest.{test_id}"

    # Start coverage for this test with context
    _per_test_cov = coverage.Coverage(
        data_file=str(coverage_file),
        source=["clk"],
        context=context_name,
    )
    _per_test_cov.start()

    yield

    # Stop and save coverage for this test
    if _per_test_cov is not None:
        _per_test_cov.stop()
        _per_test_cov.save()
        _per_test_cov = None


@pytest.fixture(autouse=True)
def rootdir(request):
    tempdir = Path(tempfile.gettempdir()) / "clk-tests"
    if not tempdir.exists():
        os.makedirs(tempdir)
    root = tempfile.mkdtemp(dir=tempdir, prefix=request.node.name[len("test_") :] + "_")
    prev = os.getcwd()
    os.chdir(root)
    os.environ["CLK_TEST_ROOT"] = str(Path(root))
    os.environ["CURRENT_CLK"] = str(Path(__file__).parent.parent)
    os.environ["CLKCONFIGDIR"] = str(Path(root) / "clk-root")
    os.environ["XDG_CACHE_HOME"] = str(Path(root) / "cache")
    # Set test identifier for per-test coverage files
    os.environ["CLK_COVERAGE_TEST_ID"] = _test_id_from_nodeid(request.node.nodeid)
    # Set context name for coverage (used by Lib.cmd)
    os.environ["CLK_COVERAGE_CONTEXT"] = _short_test_name(request.node.nodeid)
    print(root)
    (Path(root) / ".envrc").write_text('export CLKCONFIGDIR="$(pwd)/clk-root"')
    Lib.run("direnv allow")
    yield root
    del os.environ["CLKCONFIGDIR"]
    del os.environ["XDG_CACHE_HOME"]
    del os.environ["CLK_TEST_ROOT"]
    del os.environ["CURRENT_CLK"]
    del os.environ["CLK_COVERAGE_TEST_ID"]
    del os.environ["CLK_COVERAGE_CONTEXT"]
    # Clean up COVERAGE_FILE to avoid leaking to subsequent tests
    os.environ.pop("COVERAGE_FILE", None)
    os.chdir(prev)


@pytest.fixture()
def pythondir():
    res = Path(os.environ["CLKCONFIGDIR"]) / "python"
    if not res.exists():
        os.makedirs(res)
    return res


@pytest.fixture()
def bindir():
    res = Path(os.environ["CLKCONFIGDIR"]) / "bin"
    if not res.exists():
        os.makedirs(res)
    return res


class Lib:
    # Track first call per test for coverage combining
    _first_call_per_test = {}

    def __init__(self, bindir):
        self.bindir = bindir

    def assert_intrusive(self):
        assert os.environ.get("CLK_ALLOW_INTRUSIVE_TEST") == "True", "Intrusive test"

    @staticmethod
    def run(cmd, *args, **kwargs):
        return check_call(split(cmd), *args, **kwargs)

    @staticmethod
    def out(cmd, with_err=False, *args, **kwargs):
        if with_err:
            kwargs["stderr"] = STDOUT
        return check_output(split(cmd), *args, encoding="utf-8", **kwargs).strip()

    def cmd(self, remaining, *args, **kwargs):
        # Save and clear COVERAGE_FILE so subprocess writes to local .coverage
        saved_coverage_file = os.environ.pop("COVERAGE_FILE", None)
        # Get context name from environment
        context_name = os.environ.get("CLK_COVERAGE_CONTEXT", "")
        try:
            context_arg = f"--context={context_name}" if context_name else ""
            command = (
                f"python3 -u -m coverage run --source clk {context_arg} -m clk "
                + remaining
            )
            res = self.out(command, *args, **kwargs)
        finally:
            old_dir = os.getcwd()
            current_coverage_location = (Path(os.getcwd()) / ".coverage").resolve()
            coverage_location = (Path(__file__).parent).resolve()
            assert current_coverage_location != coverage_location

            # Use per-test coverage file if test ID is set
            test_id = os.environ["CLK_COVERAGE_TEST_ID"]
            coverage_file = coverage_location / f".coverage.{test_id}"

            # Set COVERAGE_FILE for the combine command
            os.environ["COVERAGE_FILE"] = str(coverage_file)

            combine_command = "coverage combine "
            is_first_call = test_id not in Lib._first_call_per_test
            if is_first_call:
                Lib._first_call_per_test[test_id] = True
            else:
                combine_command += " --append "

            combine_command += str(current_coverage_location)
            os.chdir(Path(__file__).parent)
            self.run(combine_command)
            os.chdir(old_dir)

            # Restore original COVERAGE_FILE if it was set
            if saved_coverage_file is not None:
                os.environ["COVERAGE_FILE"] = saved_coverage_file
        return res

    def create_bash_command(self, name, content):
        path = self.bindir / name
        path.write_text(content)
        path.chmod(0o755)

    def use_config(self, name):
        rootdir = Path(os.environ["CLKCONFIGDIR"])
        if rootdir.exists():
            rmtree(rootdir)
        copytree(Path(__file__).parent / "profiles" / name, rootdir)

    def use_project(self, name):
        rootdir = Path(os.environ["CLKCONFIGDIR"])
        project_dir = rootdir.parent / ".clk"
        if project_dir.exists():
            rmtree(project_dir)
        copytree(Path(__file__).parent / "profiles" / name, project_dir)


@pytest.fixture
def lib(bindir):
    return Lib(bindir)
