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


# Tangling:1 ends here
