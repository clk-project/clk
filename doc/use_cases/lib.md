- [Getting files](#780a9f7a-801f-4f4b-83ef-7bfffdf71372)
- [Running programs](#4416a8cc-4d3a-4162-a590-a67be3f9033a)

There are several stuff that you will always need to have at hand when developing command line commands.


<a id="780a9f7a-801f-4f4b-83ef-7bfffdf71372"></a>

# Getting files

Often, files are available as zip of tar archives in web servers. A function that, given a url, would download and extract its content would be very useful.

```python
from pathlib import Path

from clk.lib import extract

f = Path("readme")

assert not f.exists()
extract("https://github.com/clk-project/clk/raw/main/tests/zipfile.zip")
assert f.exists()
assert f.read_text() == "hello from some zip file\n"
```

If you wish to simply download the file, just call download. See [fetching and displaying JSON data](fetching_and_displaying_json_data.md) for a complete example of using `download`.

When you know what the file should be, say so with `sha256`.

```python
from clk.lib import download

archive = download(
    "https://github.com/clk-project/clk/raw/main/tests/zipfile.zip",
    sha256="702bb46372dfad9632c8dc3d8b5bbe945f9efd2f5575723bf66a0128486b7fb5",
)
assert archive.exists()
```

Should the server hand you anything else, nothing is written at all.

```python
import click
import pytest

archive.unlink()
with pytest.raises(click.ClickException):
    download(
        "https://github.com/clk-project/clk/raw/main/tests/zipfile.zip",
        sha256="0" * 64,
    )
assert not archive.exists()
```

When the server says how big the file is and you are looking at a terminal, `download` draws a progress bar as it goes. Here we hand it a terminal that keeps what was drawn on it.

```python
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
```


<a id="4416a8cc-4d3a-4162-a590-a67be3f9033a"></a>

# Running programs

`check_output` hands you what the program wrote. When it fails, it tells what the program said on its error output before raising, so you don't have to.

```python
import subprocess

import pytest

from clk.lib import check_output

with pytest.raises(subprocess.CalledProcessError) as failure:
    check_output(["bash", "-c", "echo 'model.cpp:42: chaos is not defined' >&2 ; exit 2"])

assert failure.value.returncode == 2
assert failure.value.stderr == "model.cpp:42: chaos is not defined\n"
```

A program that wins while complaining keeps its complaint, which goes to your error output, and you get its answer.

```python
from clk.lib import check_output

assert check_output(
    ["bash", "-c", "echo 'linking takes a while' >&2 ; echo ./build/simulator"]
) == "./build/simulator\n"
```
