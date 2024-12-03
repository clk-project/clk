- [a simple example to illustrate click.Choice](#3041aa9c-8e50-4ce4-8e92-255d4f153c8d)
- [showing the usage of Suggestion](#63e4db36-5877-424f-a31f-a8889a07a933)
- [showing the usage of DocumentedChoice](#917d3f0f-e794-4403-88fb-c02734364082)

When you want to give some choice to the user of your application, you can make use of the click built-in `Choice` types.


<a id="3041aa9c-8e50-4ce4-8e92-255d4f153c8d"></a>

# a simple example to illustrate click.Choice

I have a clk command that allow me to automate some stuffs with some devices I have accumulated along the years.

The group of commands looks like this.

```python
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
type=click.Choice(devices),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
```

And I create bash commands for stuff I want to do with my android devices, like getting the battery status.

```bash
clk command create bash android.battery.status --force --description "Print the battery level of the device" --body 'echo "Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for ${ANDROID_DEVICE} available at ${ANDROID_SERIAL}"'
```

With that code, I can now get the battery status of the cink-peax phone with

```bash
clk android -d cink-peax battery status
```

    Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for cink-peax available at 192.168.1.10:5555

The good think with Choice is that it forces me to stick to the predefined choices.

For instance, if I use a name not known, I get

```bash
clk android -d cinkpeax battery status
```

    Usage: clk android [OPTIONS] COMMAND [ARGS]...
    error: Invalid value for '--device' / '-d': 'cinkpeax' is not one of 'cink-peax', 'i9300', 'klipad'.


<a id="63e4db36-5877-424f-a31f-a8889a07a933"></a>

# showing the usage of Suggestion

Imagine now that you want to control a new device that you only have temporarily, it would be nice to simply provide its name and have clk use it verbatim. To do so, the Suggestion types might be a good candidate.

Instead of using `click.Choice`, we will use `Suggestion`. In case of mismatch, we will simply use the value as is.

```python
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
from clk.types import Suggestion
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
    type=Suggestion(devices),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
```

Now, you can call something like this.

```bash
clk android -d 192.168.1.14:5555 battery status
```

    Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for 192.168.1.14:5555 available at 192.168.1.14:5555

Of course, you don't have the failsafe that provided `click.Choice` anymore. The predefined values are still available for completion though.

```bash
clk android -d kli<TAB>
```

    klipad


<a id="917d3f0f-e794-4403-88fb-c02734364082"></a>

# showing the usage of DocumentedChoice

If you have several devices, you might want to have some more information about them in the help. To do that, make use of `DocumentedChoice`.

```python
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
from clk.types import DocumentedChoice
docs = {
    'cink-peax': 'My pomodoro',
    'i9300': 'My vacuum automator',
    'klipad': 'The photo gallery',
}
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
    type=DocumentedChoice(docs),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
```

Now, in case of error, you get a nicer message indicating the purpose of the devices.

```bash
clk android -d cinkpeax battery status
```

    Usage: clk android [OPTIONS] COMMAND [ARGS]...
    error: Invalid value for '--device' / '-d': 'cinkpeax'.
    error: Choose from:
    error:   cink-peax    My pomodoro
    error:   i9300        My vacuum automator
    error:   klipad       The photo gallery

It would be even nicer if the documentation was shown in the result of `--help` or somehow in the completion, but it is not the case for now.

Yet, the completion still works like expected.

```bash
clk android -d i<TAB>
```

    i9300

Note that we simply copied `DocumentedChoice` from the dying project [click-completion](https://github.com/click-contrib/click-completion). It will probably evolve to be more feature complete, or perhaps merged with `Suggestion` to allow providing both feature at the same time. Pull requests are more than welcome here!
