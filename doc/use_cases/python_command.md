- [adding options and arguments](#adding-options-and-arguments)
- [adding a default value](#adding-a-default-value)
- [possible mistake: forgetting the decorator](#forgetting-the-decorator)
- [possible mistake: using periods in python command names](#periods-in-python-command-names)
- [shipping data along with the command](#shipping-data-along-with-the-command)

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

  This is a built-in command.

Positional arguments:
  NAME  The name of the new command

Options:
  --open / --no-open   Also open the file after its creation  [default: open]
  --force              Overwrite a file if it already exists
  --group / --command  Bootstrap a command or a group of commands  [default: command]
  --with-data          Create a directory module instead of a single file. So that you can ship data with it
  --body TEXT          The initial body to put  [default: ""]
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

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command


@command()
def mycommand():
    "Command that says something"
    print("something")
```

```bash
clk mycommand
```

    something


<a id="adding-options-and-arguments"></a>

# adding options and arguments

You can add options and arguments to your command using click decorators. clk provides wrappers for them in `clk.decorators`.

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command, argument


@command()
@argument("name", help="Your name")
def mycommand(name):
    "A command that requires a name"
    print(f"Hello, {name}!")
```

An argument is required by default. Calling the command without it produces an error.

```bash
clk mycommand 2>&1
```

    Usage: clk mycommand [OPTIONS] NAME
    error: Missing argument 'NAME'.

Providing the argument works as expected.

```bash
clk mycommand World
```

    Hello, World!


<a id="adding-a-default-value"></a>

# adding a default value

You can make an argument optional by providing a `default` value. You can also add options and flags.

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command, option, argument


@command()
@option("--name", default="world", help="Name to greet")
@option("--use-name", default="world", help="Name to greet", deprecated="since forever")
@argument("greeting", default="Hello")
def mycommand(name, greeting, use_name):
    "A greeting command"
    name = name or use_name
    print(f"{greeting}, {name}!")
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

```bash
clk mycommand --use-name clk Goodbye
```

    DeprecationWarning: The option 'use_name' is deprecated. since forever
    warning: The parameter 'greeting' in the command 'mycommand' has no documentation
    Goodbye, world!


<a id="forgetting-the-decorator"></a>

# possible mistake: forgetting the decorator

When creating python custom commands manually, you need to use the `@command()` or `@group()` decorator from clk. If you forget to do so, clk will provide a helpful error message. Note however that if you use `clk command create`, you should not worry about that.

Let's create a python file that defines a function but forgets to decorate it.

```python
def pyenv():
    """My environment command"""
    print("hello")
```

Now try reaching it.

```bash
clk py<TAB>
```

    python

It does not come up. That is the hint that something is wrong with it, and running it says what.

```bash
clk pyenv 2>&1|sed "s|$(pwd)|.|"
```

    error: Found the command pyenv in the resolver customcommand but could not load it.
    warning: Failed to get the command pyenv: The file ./clk-root/python/pyenv.py must contain a click command or group named pyenv, but found a function instead. Did you forget the @command or @group decorator?
    error: clk.pyenv could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error

That last line promises a stacktrace, and `clk --develop` keeps the promise. It is long, so let's only keep the line clk gave up on.

```bash
clk --develop pyenv 2>&1 | grep -o 'raise BadCustomCommandError('
```

    raise BadCustomCommandError(

To fix this, simply add the `@command()` decorator from clk.

```python
from clk.decorators import command

@command()
def pyenv():
    """My environment command"""
    print("hello")
```

Now the command works as expected.

```bash
clk pyenv
```

    hello


<a id="periods-in-python-command-names"></a>

# possible mistake: using periods in python command names

Unlike bash commands, where the period character can be used to put a command inside a group (e.g. `somegroup.somecommand`), python command names cannot contain periods. The name is used as a Python identifier, so periods would produce invalid code.

```bash
clk command create python something.with.periods 2>&1
```

    Usage: clk command create python [OPTIONS] NAME
    error: 'something.with.periods' is not a valid Python command name (it contains periods). Python command names must be valid Python identifiers. If you want to create a command inside a group, first create the group with 'clk command create python --group mygroup', then add the command inside it.

To create a command inside a group, first create the group as a python command with `--group`, then edit it to add the child command inside.

```bash
clk command create python --group mygroup
```

Then edit the group file to add the child command.

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import group, command


@group()
def mygroup():
    "My group of commands"


@mygroup.command()
def child():
    "A command inside mygroup"
    print("hello from mygroup child")
```

```bash
clk mygroup child
```

    hello from mygroup child


<a id="shipping-data-along-with-the-command"></a>

# shipping data along with the command

A command sometimes needs files of its own: a template, a key, a picture. With `--with-data`, it becomes a folder instead of a single file, and those files live in it.

```python
from pathlib import Path

from clk.decorators import command


@command()
def greet():
    """Greet the way this machine greets"""
    print((Path(__file__).parent / "greeting.txt").read_text().strip())
```

```bash
clk command create python greet --with-data --description "Greet someone" --body '
from pathlib import Path

from clk.decorators import command


@command()
def greet():
    """Greet the way this machine greets"""
    print((Path(__file__).parent / "greeting.txt").read_text().strip())
'
```

It is a package now, so the command is its `__init__.py`.

```bash
clk command which greet | sed "s|$(pwd)|.|"
```

    ./clk-root/python/greet/__init__.py

Put the file it wants next to it.

```bash
echo "Hello, and welcome aboard" > "$(dirname "$(clk command which greet)")/greeting.txt"
```

```bash
clk greet
```

    Hello, and welcome aboard
