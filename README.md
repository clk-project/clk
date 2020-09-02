*\(Draft\)* click-project
==============================================================================

Click-project makes it *easy* and fun for ***you*** to create *awesome* command line interfaces!

Turn your scripts into a powerful cli without pain and get instant access to stuff like:

- great completion support
- persistence of options and arguments
- commands flow management
- launchers
- aliases
- and more...

click-project is a very *opinionated framework*, and is meant to be *batteries included*, meaning we gathered all the stuff we wanted while creating various commands. Dogfooding in mind, the developers are extensive users of click-project. They like it and when something feels wrong, they just change it.

# Why?

* This is very related to *argparse*. Why not just use *argparse*?

See [Click - why?](https://click.palletsprojects.com/en/7.x/why/)

* This is very related to *click*. Why not just use *click*?

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

## A quick tour of click-project

Ok, now you have got a fresh installation of `click-project` and have access to the
`clk` command line tool (beware pip install executable files by default in
`~/.local/bin`. Try adding this directory in your PATH in case it is not already
available).

We are first going to try together the `clk` tool so that you can quickly have
an overview of what it is capable of, then we will look into how creating your
own command line tools with the same awesome power.

### Setting up the completion

A great command line tool comes with a great completion support. run `clk
completion install bash` (or `fish` or `zsh`, your mileage may vary). If you
want to have case insensitive completion (I do), run it like `clk completion
--case-insensitive install`. `click-project` will have added the completion
content into `~/.bash_completion`. It generally needs only to start a new terminal
to have it working. In case of doubt, make sure this file is sourced into your
bashrc file.

### Using the `clk` executable
`clk` is very practical to play with `click-project` before starting a real command
line application. You can also (I do) simply use `clk` tool to automate your task
if you don't mind starting all your calls with `clk`.
#### A quick glance at the available commands

Just run `clk` to see all the available commands. Those allow configuring
precisely how you want `clk` to behave.

For the sake of the example, let's play with the echo command.

`clk echo --help` tells us that the echo command simply log a message. Try `clk
echo hello` for instance.

Now, try using some color with `clk echo hello --style blue`. Doing so, try
pressing sometimes the `<TAB>` character to see how `clk` tries to provide
meaningful completion.

Now imagine you always want the echo command to have the blue style. It would be
cumbersome to add the `--style blue` everytime, wouldn't it?

Try `clk parameters set echo --style blue`, then run `clk` echo hello and see how
it is shown in blue without you explicitly adding it.

Now, let's try to create another command, based on the echo command. For
instance, if you want a command to say hello a lot, you might want to avoid
typing `clk echo hello` everytime. You might want to use the previous magic to
add hello to the `echo` command. That would work, but it also would make the `echo`
command always say hello, that would be strange. Let's use another magic feature
of `clk`: aliases.

`clk alias set hello echo hello`. It means create the alias command named `hello`
that runs `echo hello`. Try it with `clk` hello and see that it not only says hello,
but still respect the style of `echo` and says it in blue. You can still change
the style afterward using the style like in the previous examples. `clk hello
--style red` would print it in red for instance. Notice that the configuration of
`echo` is dynamically used, meaning changing the parameters of echo would change
the behavior of hello. For instance, `clk parameters set echo --style yellow`
would make the hello command print in yellow as well.

#### Start adding your custom command

It sounds great, but you might want to do more than saying things in your
scripts. For instance, you might want a cow to say something for you.

Let's try to install cowsay (`python3 -m pip install cowsay`)
and add your first custom command.

The fastest way to do this it to add a custom shell script. First, decide a
directory that would contain your `clk` commands (say `~/clk_commands`), then add
the file cowsay.sh with the following

```bash
#!/bin/bash -eu

usage () {
    cat<<EOF
$0 A cow says something

Make a cow say something
--
A:word:str:The word to say
F:--shout/--dont-shout:Shout the word
EOF
}

if [ $# -gt 0 ] && [ "$1" == "--help" ]
then
	usage
	exit 0
fi

WORD="${CLK___WORD}"
if [ -n "${CLK___SHOUT}" ]
then
    WORD="$(echo "${WORD}"|tr '[:lower:]' '[:upper:]')!"
fi

cowsay "${WORD}"
```

You can see here several things to consider.

First, your program MUST handle being called with the argument --help so that
`clk` know how to access its documentation, process it and use its magical power
with it.

Then, after the two dashes, the documentation string may contains some metadata
to indicate `clk` how to handle it.

Finally, `clk` will run the commands with several environment variables (all
starting with CLK_). It is its way of passing information, like the arguments.

With the instruction `A:word:str:The word to say` we indicated that the command
takes one argument, named word, of type string with the documentation `The word
to say`. Likewise, `F:--shout/--dont-shout:Shout the word` indicates a flag
whether to shout the word or not.

`clk` is now able to call this command with `clk cowsay@sh`, try first `clk
cowsay@sh --help` to see how the argument was captured by `clk`.

Then, simply run `clk cowsay@sh hello`.

The command is integrated with the magick of `click-project`. For instance, you
can call `clk parameters set cowsay@sh --shout` to set the value of shout as
being true by default. To temporary disable the shouting, simply call it with
`--dont-shout`. Of course, it can be part of an alias as well.

#### Adding a python custom command

Providing a bash script as a command is a very powerful way to take advantage of
the `click-project` magic, but if you want to do more than a simple script of a
few line of code, write it in python.

Let's first try to create the python equivalent of the cowsay script.

Decide a location to store the python custom commands and indicate this location
to `click-project`. For example, if you want to put your custom python commands
into the folder `~/clk_python`, run `clk customcommands add-python-path
~/clk_python`.

Then, open the file `~/clk_python/cowsay.py` and write the following

```python
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import cowsay as cowsaylib
import click
from click_project.decorators import command, argument, flag, option


@command()
@argument("word", help="The word to say")
@flag("--shout/--dont-shout", help="Shout the word")
@option("--animal", type=click.Choice(cowsaylib.char_names),
        help="The animal that will speak", default="cow")
def cowsay(word, shout, animal):
    """Let the cow say something"""
    if shout:
        word = word.upper() + "!"
    speaker = getattr(cowsaylib, animal)
    speaker(word)
```

Try it with `clk cowsay`

### Creating a real life application
In case you want to be able to create your own command line application, instead
of running `clk` everytime.

#### (tip) An hack with aliases

Say you are satisfied with the `clk cowsay` command and simply want to reduce it
to `cs` for instance. You might be tempted to create an alias like `alias
cs="clk cowsay"`. This would work but lose the awesome completion.

Actually, if you get a close look at the completion script, you can find out how
to easily trick it to get the completion for your alias.

For instance, the bash completion for `clk` looks like.

```bash
_clk_completion() {
    local IFS=$'\t'
    COMPREPLY=( $( env COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   _CLK_CASE_INSENSITIVE_COMPLETION=ON \
                   _CLK_COMPLETE=complete-bash $1 ) )
    return 0
}

complete -F _clk_completion -o default clk
```

By adjusting the values of the variables, you can easily create your own
completion script. For instance, in the case of cs="clk cowsay", we must trick
`clk` into believing the command line was "clk cowsay". This means that we must
add "clk cowsay" in front of `COMP_WORDS` and remove its first word (which
cs). Then, the `COMP_CWORD` must be incremented for there is one more word to take
into account.
The script should then look like

```bash
_cs_completion() {
    local IFS=$'\t'
    COMPREPLY=( $( env COMP_WORDS="clk cowsay ${COMP_WORDS[*]:1}" \
                   COMP_CWORD=$((COMP_CWORD + 1)) \
                   _CLK_CASE_INSENSITIVE_COMPLETION=ON \
                   _CLK_COMPLETE=complete-bash clk ) )
    return 0
}

complete -F _cs_completion -o default cs
```

Of course, it is more of a dirty trick to simplify your personal commands than a
way to produce a full blown command line application. But since several people
do that alias trick, it was worth mentioning how to get the awesome completion
also.

#### Create your project

Let's say that we want to produce a nice command line application with the look
and feel of `clk` and distribute it. We are not up-to-date with all the fancy ways
of creating a project like poetry, so we will stick here with the classical
setuptools way.

For the time being, we don't provide a way to simply create a command line
application without subcommands.

In the example, we will create an application called cowsaycli (to avoid the
overlap with cowsay that we will be using).

There is nothing unusual to do, write the setup.py file at the root of your
project with a content like.

```python
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from setuptools import setup, find_packages

setup(
    name='cowsaycli',
    version="0.0.0",
    author='Moran Laura',
    author_email='moranlaura@wolfe.com',
    description='Let the animals speak',
    packages=find_packages(),
    zip_safe=False,
    install_requires=[
        "click-project~=0.12.0",
    ],
    entry_points={
        'console_scripts':
        [
            'cowsaycli=cowsaycli.main:main',
        ]
    },
)
```

We opinionatedly considered the main entry point would be in
`cowsaycli.main.main`, but feel free to do as it pleases you.

Then, in the file `cowsaylib/main.py`, add the following.

```python
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from click_project.setup import basic_entry_point, main
from click_project.decorators import command, argument, flag, option


@basic_entry_point(
__name__,
extra_command_packages=["cowsaycli.commands"],
)
def cowsaycli(**kwargs):
    """Make the animals talk"""


if __name__ == "__main__":
    main()
```

Here, we simply define a function, the main entry point.

Running `python3 -m pip install -e cowsaycli`, you can have access to the
executable `cowsaycli`, that behave exactly like `clk`. The instruction
`extra_command_packages=["cowsaycli.commands"]` indicates that every python
module that can be imported as `cowsaycli.commands.<name>` and follows the exact
same convention as custom commands will be considered a sub command of
`cowsaycli`. This is useful, as you just have to populate the folder
`cowsaycli/commands/` with all the commands you like.

For instance, let's copy the `cowsay.py`  file made earlier into this
folder. Great, you now have your own application, called `cowsaycli`, that can be
run like `cowsaycli cowsay --animal cheese test` and that is ready to be
distributed the usual way.

### Where is the *completion*?

First, you need to install it. For example in a bash shell, you can type:
```bash
clk completion install
source ~/.bash_completion
```

Now, try something like `clk hell<TAB> --co<TAB> 5`.

### What is this *command flow management*?

Say you made other commands `whatsup.py` and `bye.py`:

```python
# whatsup.py
import click
from click_project.decorators import command

@command()
def whatsup():
    """Simple program that says bye."""
    click.echo("What's up?!")
    click.echo("Awesome!")
```

```python
# bye.py
import click
from click_project.decorators import command

@command()
def bye():
    """Simple program that says bye."""
    click.echo("Bye!")
```

You might want to *chain* them and often do something like `clk hello && clk whatsup && clk bye`.

Well, you can define precedence links of your commands like this:
```
clk flowdeps set whatsup hello
clk flowdeps set bye whatsup
```
Then, try: `clk bye --flow` ! :)
The output should look something like:
```
Running step 'hello'
hello
Running step 'whatsup'
What's up?!
Awesome!
Bye!
```
Bonus: `clk flowdeps graph mycommand` let's you see the dependency graph for `mycommand` in a nice visual way!

Want more? Have a look at `clk flowdeps --help`!

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
