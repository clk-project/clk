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


# Tangling:1 ends here
