#!/usr/bin/env python3

from pathlib import Path

import pytest

from clk import lib


def test_ln():
    Path("a").write_text("a")
    lib.ln("a", Path("b"))
    assert Path("b").read_text() == "a"
    Path("a").write_text("b")
    assert Path("b").read_text() == "b"
    with pytest.raises(FileExistsError):
        lib.ln(Path("a"), "b")
    lib.dry_run = True
    lib.ln(Path("a"), "b")
    lib.dry_run = None
    lib.rm("a")
    with pytest.raises(FileNotFoundError):
        Path("b").read_text()


def test_rm():
    a = Path("a")
    b = Path("b")
    a.write_text("a")
    lib.ln(a, b)

    # check that a symlink to an existing file gets removed
    assert b.is_symlink()
    lib.rm(b)
    assert not b.is_symlink()

    assert a.exists()
    lib.rm(a)
    assert not a.exists()

    # a is gone. check that a dangling symlink gets removed
    lib.ln(a, b)
    assert b.is_symlink()
    lib.rm(b)
    assert not b.is_symlink()

    # now, check that the missing a don't raise an error if removed again
    lib.rm(a)


def test_link():
    Path("a").write_text("a")
    lib.link("a", Path("b"))
    assert Path("b").read_text() == "a"
    Path("a").write_text("b")
    assert Path("b").read_text() == "b"
    with pytest.raises(FileExistsError):
        lib.link(Path("a"), "b")
    lib.dry_run = True
    lib.link(Path("a"), "b")
    lib.dry_run = None
    lib.rm("a")
    assert Path("b").read_text() == "b"


def test_natural_time():
    assert lib.natural_time(5) == "5 seconds ago"


def test_safe_check_output():
    assert lib.safe_check_output("something_crazy") == ""


def test_safe_check_output_on_path():
    printf_path = Path(lib.which("printf"))
    assert lib.safe_check_output([printf_path, "test"]) == "test"


def test_check_output_on_path():
    printf_path = Path(lib.which("printf"))
    assert lib.check_output([printf_path, "test"]) == "test"
