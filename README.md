*\(Draft\)* click-project
==============================================================================

Click-project makes it *easy* and fun for ***you*** to create *awesome* command line interfaces!

For now, if is focused on command line interfaces with several groups of
commands (like `git`, `vault`, `nomad`, `consul`, `ipfs`, `kubectl` etc).

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
* log management: TODO
* a powerful third party lib
* a nice tabular printer
* native handling of the color
* a native dry-run mode
* ...

We decided to put all that in a single framework.

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

# A quick tour of click-project

When you install `click-project`, a command line tool called `clk` is installed
also. You may want to play a little bit with it to get the look and feel.

First, run `clk --help` or more simply `clk`. See, there are already plenty of
commands already available.

Ok, now you have got a fresh installation of `click-project` and have access to the
`clk` command line tool (beware pip install executable files by default in
`~/.local/bin`. Try adding this directory in your PATH in case it is not already
available).

We are first going to try together the `clk` tool so that you can quickly have
an overview of what it is capable of, then we will look into how creating your
own command line tools with the same awesome power.

## Setting up the completion

A great command line tool comes with a great completion support. run `clk
completion install bash` (or `fish` or `zsh`, your mileage may vary). If you
want to have case insensitive completion (I do), run it like `clk completion
--case-insensitive install`. `click-project` will have added the completion
content into `~/.bash_completion`. It generally needs only to start a new terminal
to have it working. In case of doubt, make sure this file is sourced into your
bashrc file.

## Using the `clk` executable
`clk` is a very practical tool. It allows you to quickly play with
`click-project` before starting a real command line application. Everything you
will taste with `clk` will also be available to your own command line
application based on `click-project`. You can also (like I do) simply use `clk`
tool to manage your personal « scripts » and take advantage of all the magic of
`click-project`, if you don't mind starting all your calls with `clk`.

Because `clk` is the demonstrator and is closely related to `click-project`, we
might mention `clk` to say `click-project` in the following documentation.

### A quick glance at the available commands

Just run `clk` to see all the available commands. Those allow configuring
precisely how you want `clk` to behave.

For the sake of the example, let's play with the `echo` command.

`clk echo --help` tells us that the echo command simply logs a message. Try `clk
echo hello` for instance.

Now, try using some color with `clk echo hello --style blue`. Doing so, try
pressing sometimes the `<TAB>` character to see how `clk` tries to provide
meaningful completion. You can try several styles, like `bg-blue,fg-green`. The
completion should help you write a correct style.

Now imagine you always want the echo command to have the blue style. It would be
cumbersome to add the `--style blue` everytime, wouldn't it?

One of the magic of `clk` is the ability to save your default settings. That
way, even if a command comes with a sensible default, you can always change it
to fit your needs more precisely.

Try `clk parameters set echo --style blue`, then run `clk` echo hello and see how
it is shown in blue without you explicitly adding it.

Another of the magic of `clk` is the ability to construct commands from other
commands. For instance, if you like the `echo` command and you want to use a lot
the command `clk echo hello` you might want create a separate command to do
so. A way to do this would be to use `parameters` to add `hello` to the `echo`
command. That would work, but it also would make the `echo` command always say
hello, would be strange. Let's use the other magic feature of `clk`: aliases.

Run `clk alias set hello echo hello`. It means create the alias command named
`hello` that runs `echo hello`. Try it with `clk hello` and see that it not only
says hello, but still respect the style of `echo` and says it in blue. You can
still change the style afterward using the style like in the previous
examples. `clk hello --style red` would print it in red for instance. Notice
that the configuration of `echo` is dynamically used, meaning changing the
parameters of echo would change the behavior of hello. For instance,
`clk parameters set echo --style yellow` would make the hello command print in yellow
as well.

### Play with the notion of project

The commands like `parameters` and `alias` edit a configuration file. This file
is by default stored in `~/.config/clk/clk.json`.

Do you remember how `git` stores configuration globally with `~/.gitconfig` and
locally with `./.git/config`? `clk` does the same. One of the power of
`click-project` lies in the fact your configuration can be stored in several
places, the local one having the precedence over the global one. The location
storing local setting is what we call a project (hence the name).

Create a directory `~/clk_project`, that we will call your project. Then create
the directory `~/clk_project/.clk` to let `clk` understand this is a
project. Actually, the `.clk` folder has the exact same meaning for `clk` as the
`.git` folder for `git`. To find a project, `clk` we try to find a sub-directory
called `.clk` in the current working directory or in any of its parents, exactly
like `git`. You can alternatively provide the option `--project ~/clk_project`
to indicate the project for the time of the command line execution, just like
the `-C <path>` in `git`.

Enter the `~/clk_project/` directory and run `clk parameters set echo --style
green`. You could achieve the same result running `clk --project
~/clk_project parameters set echo --style green`.

The configuration of the parameter is recorded locally in the project
`~/clk_project`, more precisely in the file `~/clk_project/.clk/clk.json`.

Try, running `clk echo test`, inside and outside the project to find out the
color is different. This is because when `clk` figures out it is in the context
of the project (for example because your current working directory is a sub
directory of `~/clk_project/`), then the local parameters are used on top of the
global parameters.

To have a better understanding of how a command will be called, you can simply
run `clk echo --help`. The following line should be in the output.

`The current parameters set for this command are: --style yellow --style green --help`

You can see that the global parameters are not forgotten, they are simply on the
left. The magic of `click` is so that the parameter on the right takes precedence.

In case you want more information about the parameters of the command, simply
run.  `clk parameters show echo`. The output should show the global parameters
in blue and the local parameters in green.

When you have several parameters, it is very useful to run this command to
understand what has happened.

This behavior of local stuff overriding local stuff is also available in aliases.

In `~/clk_project/`, run `clk alias set hello echo hello from clk_project`. Now
run the command `clk hello` from inside and outside the project to find out that
the local alias is used instead of the global one when you are inside the
project.

### Start adding your custom command

It sounds great, but you might want to do more than saying things in your
scripts, right? For instance, you might want a cow to say something for you.

Let's try to install cowsay (`python3 -m pip install cowsay`)
and add your first custom command.

The fastest way to do this it to add a custom shell script. First, decide a
directory that would contain your `clk` commands (say `~/clk_commands`).

Then indicate to `clk` that this folder is meant to contain custom commands with
`clk customcommands add-external-path ~/clk_commands`.

In case you don't want to put your commands in a specific folder, you could also
put the command in the canonical folder of `click-project` (`~/.config/clk/bin`).

Add the file `cowsay.sh` with the following.
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

First, your program MUST handle being called with the argument `--help` so that
`clk` know how to access its documentation, process it and use its magical power
with it.

Then, after the two dashes, the documentation string may contains some metadata
to indicate `clk` how to handle it.

Finally, `clk` will run the commands with several environment variables (all
starting with `CLK_...`). It is its way of passing information, like the arguments.

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

### Adding a python custom command

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

## Creating a real life application
In case you want to be able to create your own command line application, instead
of running `clk` every time.

### (tip) An hack with aliases

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

### Create your project

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
exclude_core_commands=["git-sync"],
)
def cowsaycli(**kwargs):
    """Make the animals talk"""


if __name__ == "__main__":
    main()
```

Here, we simply define a function, the main entry point. The part
`exclude_core_commands=["git-sync"],` indicates that this tool will behave like
`clk`, except it wont have the command `git-sync`. This is useful in case you
want to remove some of the commands of `click-project`. Alternatively, you can
use a whitelist approach setting `include_core_commands` instead of
`exclude_core_commands`, the most extreme case would be `include_core_commands`,
indicating to use none of `clk` commands.

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

## Where is the *completion*?

First, you need to install it. For example in a bash shell, you can type:
```bash
clk completion install
source ~/.bash_completion
```

Now, try something like `clk hell<TAB> --co<TAB> 5`.

## What is this *command flow management*?

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

# Playing with the recipes

Say you have several `parameters` and `aliases` that work together. For
instance, imagine you want to have an alias and a parameters that don't make
sense separately. For instance, add an alias and set its parameters :

`clk alias set hello echo hello` and `clk parameters set hello --style red`

You might want a way to make clear the fact that those two configurations work
together. Enters the recipes.

Create a new recipe with `clk recipe create hello`. By default, a recipe is disabled, so enable it with `clk recipe enable hello`.

Then configure the alias and the parameter in the recipe with.

`clk alias --recipe hello set hello echo hello` and `clk parameters --recipe hello set hello --style red`

In case you had configured the alias outside of the recipe, run `clk alias unset
hello` and `clk parameters unset hello` to have a better understanding of what
will happen.

Now, run `clk hello` to see it work as before. Run `clk recipe disable hello`
and then `clk hello` to see that `clk` complains that the `hello` command is no
more available.

`clk parameters show` and `clk alias show` indeed show nothing about hello.

The enable the recipe again, with `clk recipe enable hello` and take another
look at the parameters and aliases.

The legend indicates that those configuration are in the global/hello level,
which means « the recipe hello, defined globally ». Indeed, recipes may be
defined globally or locally and enabled or disabled globally or locally.

Manipulate those two independent dimensions (definition and enabling) may be
tricky. To find out more about the current recipes, run `clk recipe show`.

```
recipe    set_in    defined_in    link      order
--------  --------  ------------  ------  -------
hello     global    global                   1000
```

Disable it and run the command again.

As you can see, the values did not change, the recipe remains defined globally
and set globally (meaning it was disabled globally). Only the color indicate
whether it is disabled or enabled.

Try removing the setting (saying it was enabled or disabled) with `clk recipe unset hello`, then see

```
recipe    set_in    defined_in    link      order
--------  --------  ------------  ------  -------
hello     Unset     global                   1000
```

Here, the recipe is unset, then the default behavior (disabling) is used.

Finally, remove the recipe with `clk recipe remove hello`.

In conclusion, recipes are a powerful and practical way of grouping several
configuration together to manipulate them as a group.

## logging

Logging should be easy to read yet provide enough information for debugging for example. Moreover, the logging should be well separated from other outputs from the command line tool. In click project, we have created several logging levels that allows to easily change the log level required for a specific use case, and the logs are displayed with colors and on the error output by default.


- [ ] bonus
- [ ] plugins
- [ ] recipes
- [ ] niveau de log
- [ ] action pour voir ce qui serait fait
- [ ] écrire le sien
