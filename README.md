*This is currently a draft of the readme of click-project*
click-project
=============


click-project is a very *opinionated framework* to ease the creation of command line interfaces.

It is meant to be *batteries included*, meaning we gathered all the stuff we wanted while creating various commands.

Dogfooding in mind, the developers are extensive users of click-project. They like it and when something feels wrong, they just change it.

# Why?

* This is very related to *argparse*. Why not just use *argparse*?

See [Click - why?](https://click.palletsprojects.com/en/7.x/why/)

* This is very related to click. Why not just use click?

Click is very powerful when you need to create a command line tool. Yet, when we needed to create command line applications, we often wanted to reinvent the wheel by adding stuff like:

# What features?

Let's consider the example of a command line tool, say `clk`.

* great completion support, for the most used shells. Even if you use the command line, most likely you don't like typing that much, if you want to run `clk --someoption` are you barely think like us, you probably want to type `clk --s<TAB>`.
* persistence of options and arguments:
Say you want to run `clk --someoption` again and again and again. You'd like to record `--someoption` somewhere so that all the calls to `clk` will behave like `clk --someoption`.
* logging features: Having good logging capabilities is the basics of a suitable command line tool.
* powerful formatting helpers: The output of command line tools should be easy to read and easy to parse by an external tool. click-project provides some formatting features that can be easily configured from the command line to achieve this goal.
* directory based project: Say that you want to store
* argument documentation: arguments are at least as important as options, yet they don't have any documentation associated. click-project fixes that by allowing to add an help to the arguments.
* options groups: options can be grouped to structure the help of the commands.
* command flow management: TODO
* launchers: TODO
* alias: TODO

We decided to put all that in a single framework.

- [ ]  -> log management, call_process, tableprinter, couleur, dry-run


For more information of all that comes with click-project, see [#features].

# Inspirations?

click-project is inspired by several other great command line tools. Just to name a few of them:

* [git](https://git-scm.com/)
* [homebrew](http://brew.sh/)
* [haskellstack](https://haskellstack.org)
* [Docker machine](https://docs.docker.com/machine/)
* [Darcs](http://darcs.net)
* [vault](https://www.vaultproject.io/)


# Installing

A classic : `python3 -m pip install click-project`

# Getting started

When you install `click-project`, a command line tool called `clk` is installed also. You may want to play a little bit with it to get the look and feel.

First, run `clk --help` or more simply `clk`.

...

## Let's get your hands dirty: Adding your own command

Let's start with the classical hello world example.

If you are here, you might already know click. Let's use its hello example as a start.

Say you want to add a command to `clk`. `clk` is configured to import all the modules of the `clk_commands_perso` package. So start by creating this package and make it available.

```bash
mkdir -p ~/python/clk_commands_perso
export PYTHONPATH=~/python/:${PYTHONPATH}
```

Then, create the `hello.py` file under `~/python/clk_commands_perso/` with the following content:

```python
import click
from click_project.decorators import command, option


@command()
@option("--count", default=1, help="Number of greetings.")
@option("--name", prompt="Your name", help="The person to greet.")
def hello(count, name):
    """Simple program that greets NAME for a total of COUNT times."""
    for _ in range(count):
        click.echo(f"Hello, {name}!")

```

Now, you should be able to run `clk hello`! Also, have a look at `clk hello --help`.

# Getting started with your own

- [ ] cas d'une seule ligne de commande et de plusieurs lignes de commande

- [ ] comment démarrer avec clk
- [ ] la notion de project

# Features

- [ ] parameters
- [ ] alias
- [ ] externalcommands


## logging

Logging should be easy to read yet provide enough information for debugging for example. Moreover, the logging should be well separated from other outputs from the command line tool. In click project, we have created several logging levels that allows to easily change the log level required for a specific use case, and the logs are displayed with colors and on the error output by default.


- [ ] bonus
  - [ ] plugins
  - [ ] recipes
  - [ ] niveau de log
    - [ ] action pour voir ce qui serait fait
    - [ ] écrire le sien
