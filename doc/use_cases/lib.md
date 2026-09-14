- [Getting files](#780a9f7a-801f-4f4b-83ef-7bfffdf71372)

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
