To record what an application plays, I cannot simply read from it. I add a sink of my own, move the application into it, and record from there. Whatever happens next, that plumbing has to go: leave it behind and the application keeps playing into a sink nobody listens to.

I hand the function that tears it down to `clk.atexit.register`, and clk calls it when it leaves, whether the command went well or not.

Here the sound server is a couple of files, so that this page can run.

```bash
echo speakers > routing.txt
```

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import click

from clk.atexit import register
from clk.decorators import command, flag

ROUTING = Path("routing.txt")
PROXY = Path("proxy-sink.txt")


def tear_down(sink):
    ROUTING.write_text(f"{sink}\n")
    PROXY.unlink()


@command()
@flag("--disk-full", help="Pretend the disk fills up while recording")
def record(disk_full):
    "Record what the music player plays"
    sink = ROUTING.read_text().strip()
    PROXY.write_text("loaded\n")
    ROUTING.write_text("proxy\n")
    register(tear_down, sink)
    print(f"recording the music from the {ROUTING.read_text().strip()} sink")
    if disk_full:
        raise click.ClickException("no space left on device")
```

The recording takes the music through the proxy sink. Once the command is over, the music plays on the speakers again and the proxy sink is gone.

```bash
clk record
cat routing.txt
ls proxy-sink.txt 2>&1
```

    recording the music from the proxy sink
    speakers
    ls: cannot access 'proxy-sink.txt': No such file or directory

The recording may stop in the middle. The plumbing goes all the same.

```bash
clk record --disk-full 2>&1
cat routing.txt
ls proxy-sink.txt 2>&1
```

    recording the music from the proxy sink
    error: no space left on device
    speakers
    ls: cannot access 'proxy-sink.txt': No such file or directory
