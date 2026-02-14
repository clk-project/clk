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
