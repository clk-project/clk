- [adding options and arguments](#adding-options-and-arguments)
- [possible mistake: forgetting the decorator](#forgetting-the-decorator)

To create a python command, you can simply call the following command.

```bash
clk command create python mycommand
```

Your editor will be used to first edit the command. This command will already contain some code to get you started.

Note that you can always get the help of any command using `--help`. So don't hesitate to try.

```bash
clk command create python --help
```

```
Usage: clk command create python [OPTIONS] NAME

  Create a bash custom command

  The current parameters set for this command are: --no-open --force

  This is a built-in command.

Arguments:
  NAME  The name of the new command

Options:
  --open / --no-open   Also open the file after its creation  [default: True]
  --force              Overwrite a file if it already exists  [default: False]
  --group / --command  Bootstrap a command or a group of commands  [default: False]
  --with-data          Create a directory module instead of a single file. So that you can ship data with it  [default:
                       False]
  --body TEXT          The initial body to put  [default: ]
  --description TEXT   The initial description to put  [default: Description]
  --from-file TEXT     Copy this file instead of using the template
  --help-all           Show the full help message, automatic options included.
  --help               Show this message and exit.
```

Let's look at the file that was created.

```bash
cat $(clk command which mycommand)
```

```
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path

import click

from clk.decorators import (
    argument,
    flag,
    option,
    command,
    use_settings,
    table_format,
    table_fields,
)
from clk.lib import (
    TablePrinter,
    call,
)
from clk.config import config
from clk.log import get_logger
from clk.types import DynamicChoice


LOGGER = get_logger(__name__)


@command()
def mycommand():
    "Description"
```

The `@command()` decorator is provided by clk. It is a thin wrapper around the click `@command()` decorator that adds some features like automatic option handling.

Let's run this command.

```bash
clk mycommand
```

    warning: The command 'mycommand' has no documentation

If you keep the word `Description` in the help message, clk will warn you that you should replace it with something more interesting.

Let's write something in here.

```bash
sed -i 's/"Description"/"Command that says something"/g' "$(clk command which mycommand)"
```

```bash
clk mycommand --help | head -10
```

```
Usage: clk mycommand [OPTIONS]

  Command that says something

  Edit this custom command by running `clk command edit mycommand`
  Or edit ./clk-root/python/mycommand.py directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.
```

Let's make this command say something.

```bash
cat<<'EOF' > "$(clk command which mycommand)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command


@command()
def mycommand():
    "Command that says something"
    print("something")
EOF
```

```bash
clk mycommand
```

    something


<a id="adding-options-and-arguments"></a>

# adding options and arguments

You can add options and arguments to your command using click decorators. clk provides wrappers for them in `clk.decorators`.

```bash
cat<<'EOF' > "$(clk command which mycommand)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command, option, argument


@command()
@option("--name", default="world", help="Name to greet")
@argument("greeting", default="Hello")
def mycommand(name, greeting):
    "A greeting command"
    print(f"{greeting}, {name}!")
EOF
```

```bash
clk mycommand
```

    warning: The parameter 'greeting' in the command 'mycommand' has no documentation
    Hello, world!

```bash
clk mycommand --name clk Goodbye
```

    warning: The parameter 'greeting' in the command 'mycommand' has no documentation
    Goodbye, clk!


<a id="forgetting-the-decorator"></a>

# possible mistake: forgetting the decorator

When creating python custom commands manually, you need to use the `@command()` or `@group()` decorator from clk. If you forget to do so, clk will provide a helpful error message. Note however that if you use `clk command create`, you should not worry about that.

Let's create a python file that defines a function but forgets to decorate it.

```bash
cat <<'EOF' > "${CLKCONFIGDIR}/python/myenv.py"
def myenv():
    """My environment command"""
    print("hello")
EOF
```

When trying to run this command, clk will tell you that it found a function instead of a click command.

```bash
clk myenv 2>&1|sed "s|$(pwd)|.|"
```

    error: Found the command myenv in the resolver customcommand but could not load it.
    warning: Failed to get the command myenv: The file ./clk-root/python/myenv.py must contain a click command or group named myenv, but found a function instead. Did you forget the @command or @group decorator?
    error: clk.myenv could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error

To fix this, simply add the `@command()` decorator from clk.

```bash
cat <<'EOF' > "${CLKCONFIGDIR}/python/myenv.py"
from clk.decorators import command

@command()
def myenv():
    """My environment command"""
    print("hello")
EOF
```

Now the command works as expected.

```bash
clk myenv
```

    hello
