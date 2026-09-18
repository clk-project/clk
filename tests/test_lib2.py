#!/usr/bin/env python3
# [[file:../doc/use_cases/lib.org::#4deb6976-5708-4527-8ed8-c2ab9de8cc38][Tangling:1]]
# Automatically generated, don't edit


def test_extract():
    from pathlib import Path

    from clk.lib import extract

    f = Path("readme")

    assert not f.exists()
    extract("https://github.com/clk-project/clk/raw/main/tests/zipfile.zip")
    assert f.exists()
    assert f.read_text() == "hello from some zip file\n"


def test_download():
    from clk.lib import download

    archive = download(
        "https://github.com/clk-project/clk/raw/main/tests/zipfile.zip",
        sha256="702bb46372dfad9632c8dc3d8b5bbe945f9efd2f5575723bf66a0128486b7fb5",
    )
    assert archive.exists()
    import click
    import pytest

    archive.unlink()
    with pytest.raises(click.ClickException):
        download(
            "https://github.com/clk-project/clk/raw/main/tests/zipfile.zip",
            sha256="0" * 64,
        )
    assert not archive.exists()


def test_download_progress():
    import sys
    from unittest import mock

    from clk.lib import download

    class Terminal:
        "A stderr that says it is a terminal and remembers what is drawn on it"

        def __init__(self):
            self.written = ""

        def isatty(self):
            return True

        def write(self, text):
            self.written += text

        def flush(self):
            pass

    terminal = Terminal()
    with mock.patch.object(sys, "stderr", terminal):
        download("https://github.com/clk-project/clk/raw/main/tests/zipfile.zip")

    assert "100%" in terminal.written


def test_check_output_failing():
    import subprocess

    import pytest

    from clk.lib import check_output

    with pytest.raises(subprocess.CalledProcessError) as failure:
        check_output(
            ["bash", "-c", "echo 'model.cpp:42: chaos is not defined' >&2 ; exit 2"]
        )

    assert failure.value.returncode == 2
    assert failure.value.stderr == "model.cpp:42: chaos is not defined\n"


def test_check_output_noisy():
    from clk.lib import check_output

    assert (
        check_output(
            ["bash", "-c", "echo 'linking takes a while' >&2 ; echo ./build/simulator"]
        )
        == "./build/simulator\n"
    )


# Tangling:1 ends here
