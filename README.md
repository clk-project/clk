clk
==============================================================================

[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=bugs)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=code_smells)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=coverage)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=ncloc)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=duplicated_lines_density)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=alert_status)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=security_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_index)](https://sonarcloud.io/dashboard?id=clk-project_clk)


[![CircleCI](https://circleci.com/gh/clk-project/clk.svg?style=svg)](https://app.circleci.com/pipelines/github/clk-project/clk)

Come and discuss clk with us on
- [![IRC libera.chat #clk](https://raster.shields.io/badge/libera.chat-%23clk-blue)](https://web.libera.chat/?channels=#clk)
- [![Gitter](https://badges.gitter.im/clk-project/community.svg)](https://gitter.im/clk-project/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

clk is the *Command Line Kit* that aims to become a *Cognitive Load Killer*, so
that you can focus on what you are doing instead of how to how to ask the tool
to do it. You should type only what the computer could not have guessed by
itself.

Out of the box, it provides:

- great completion support
- aliases
- persistence of options and arguments
- commands flow management
- launchers
- and more...

clk is a very *opinionated framework*, and is meant to be *batteries
included*. We want to be able to create command line applications very fast
without compromising on the user experience.

clk provides a library to create your own command line application, but it also
provide an application called `clk` that already provides all the features so
that you can just add your own commands on top of it.

# Quick start

Install with `curl -sSL https://clk-project.org/install.sh | bash`
or `python3 -m pip install clk`

Now, the `clk` tool is available in `~/.local/bin/`, if that directory is not
already in your path, use `export PATH="${PATH}:${HOME}/.local/bin"`

Let's play with this tool to have a feeling of what clk is about.

Install the completion with `clk completion --case-insensitive install` and
start a new shell to take advantage of it.

Then, run `clk command` (or simply `clk`) to see the available commands.

Out of the box, `clk` only provides the commands that allow its user to create
per own tool.

For instance, let's create a command with `clk command create python say`. It
should open the command with your favorite editor (whatever is in the EDITOR
environment variable).

The command is already filled with the common imports, so that you just need to
edit the command code.

In the end of the file, replace this part

```python
@command()
def say():
    "Description"
```

With

```python
import cowsay

@command()
@argument("what", help="What to say")
@option("--who", type=click.Choice(cowsay.char_names), help="Who says", default="cow")
def say(what, who):
    "Say something with style"
    getattr(cowsay, who)(what)
```

Actually because `clk` simply provide features on top of
[click](https://click.palletsprojects.com/), please take a look at click's
documentation to understand how to write commands.

Close your editor, install the cowsay dependency `python3 -m pip install cowsay`.

And now, try:

`clk say --help`

`clk say hello`

You have created your first command!

You can see that this command already provide a nice help message.

You could have created a click command that does exactly that, without using
`clk`. So you might wonder why using clk in the first place. But now, this
command can take advantage of all the features that come with clk.

For instance, you can create aliases:

Let's create an alias called `hello` that runs the command `say` (the one you just created) with the argument `hello world`

`clk alias set hello say hello world`

And you have created another command, `hello`, that says hello. Try it with.

`clk hello`

This feature allow you to provide generic commands with a lot of power and let
your user customize those commands to fit per particular needs.

Aliasing is a good way to quickly handcraft a command from other commands.

Now, even tough you tried hard to have sensible default values, chances are that
some of the users of your commands might think otherwise, using `clk parameter`,
per can mitigate this issue.

For instance, your command hello by default make a cow say the message. But some
user might prefer the hello command to be told by a cheese.

Run:

`clk parameter set hello --who cheese`

And now try:

`clk hello`

Guess what happened?

Don't remember the parameters you have set or the alias you have set?

Run:

`clk parameter show`

and

`clk alias show`

And remove those with

`clk parameter unset hello`

`clk alias unset hello`

Want to put those parameters and aliases in a same place to enable them at once? Try creating a extension with:

`clk extension create hello`

And now, create the hello command again, but now in the extension.

`clk alias --global-hello set hello say hello`

`clk parameter --global-hello set hello --who trex`

Try the hello command again:

`clk hello`

Take a look at `clk alias show` and `clk parameter show` to see how those are
nicely put in the extension.

And see how easy it is to disable the whole hello extension at once with.

`clk extension disable hello`

And see how it cleaned the parameters and the aliases.

Remove the whole extension at once with.

`clk extension remove hello`

What is this global word in `--global-hello`?

Try creating an empty directory in

`mkdir -p ~/sometest/.clk`

Then go to sometest with `cd ~/sometest`.

Now, create the hello command again, with.

`clk alias set hello say hello`

`clk parameter set hello --who milk`

See how the output of the commands is about creating a new *local* alias and a
new *local* parameter instead of global like earlier?

Try the hello command with

`clk hello`

Now, get out of sometest with `cd ~/` and try it again to see it fail with.

`clk hello`

See how it is no more available? It is available only in the sometest directory
or any of its children directories. sometest is called a *project*.

You can override whatever command you want in a project.

Try `cd ~/sometest` and then override the say command with.

`clk alias set say echo --style fg-yellow`

Now try `clk hello`

See how the used say command is now the local one instead of the global one?

You can put whatever you want in the project, commands, parameters,
aliases etc.

Now, remove the whole stuff, with.

`clk parameter unset hello`

`clk alias unset hello`

`clk alias unset say`

`clk command remove say`

And simply install the extension I created that already does all of this with.

`clk extension install hello`

And see how it came back to life with.

`clk hello`

Remove it again with.

`clk extension remove --global hello`

Here, `--global` is needed or clk will try (and fail) to delete a
local extension, whereas the clone command defaults to install it globally.

We realize that extensions don't have yet a coherent default behavior. This is
because there are quite new and are not thoroughly used yet. We believe that the
sensible defaults will come naturally when extensions are used more often.

Hopefully you have started now to grab the awesomeness of clk and are
envisioning all the nice stuff you can do with it.

Also take a look at a [click project 101](https://konubinix.eu/braindump/fcfaaefc-1cd7-4181-a042-6665e9a49228?title=click_project_101) made by one of the authors about
clk.

# why clk?

* This is very related to *argparse*. Why not just use *argparse*?

See [Click - why?](https://click.palletsprojects.com/en/7.x/why/)

* This is very related to *click*. Why not just use *click*?

Click is very powerful when you need to create a command line tool. Yet, when we
needed to create command line applications, we often wanted to reinvent the
wheel by adding the same cool features. See below.

# What features?

Let's consider the example of a command line tool, say `clk`.

* great completion support, for the most used shells. Even if you use the command line, most likely you don't like typing that much, if you want to run `clk --someoption` are you barely think like us, you probably want to type `clk --s<TAB>`.
* persistence of options and arguments:
Say you want to run `clk --someoption` again and again and again. You'd like to record `--someoption` somewhere so that all the calls to `clk` will behave like `clk --someoption`.
* logging features: Having good logging capabilities is the basics of a suitable command line tool.
* powerful formatting helpers: The output of command line tools should be easy to read and easy to parse by an external tool. clk provides some formatting features that can be easily configured from the command line to achieve this goal.
* directory based project: Say that you want to store
* argument documentation: arguments are at least as important as options, yet they don't have any documentation associated. clk fixes that by allowing to add a help message to the arguments.
* options groups: options can be grouped to structure the help of the commands.
* command flow management: in case you tend to often call several commands in sequence. Although each command is also meaningful by itself. You can tell dependencies between command to gain kinda makefile-ish workflow when you run your commands.
* launchers: some commands are just wrappers around other tools, in such situation, it is often practical to have launcher that are prefixes put in front of the run command (like valgrind, gdb etc.)
* alias: in clk, the idea is that you create generic commands that fulfill a broad range of usages. Then you want to call those commands with your specific case in mind. Aliases allow you to create new commands that simply call sequences of other commands with custom parameters.
* log management: if you want to be able to separate log errors, information, debug stuff etc and have a color scheme to make sense of the output
* a powerful third party lib
* a nice tabular printer
* native handling of the color
* a native dry-run mode
* ...

We decided to put all that in a single framework.

For more information of all that comes with clk, see [#features].

# Inspirations?

clk is inspired by several other great command line tools. Just to name a few of them:

* [git](https://git-scm.com/)
* [homebrew](http://brew.sh/)
* [haskellstack](https://haskellstack.org)
* [Docker machine](https://docs.docker.com/machine/)
* [Darcs](http://darcs.net)
* [vault](https://www.vaultproject.io/)


# Installing

A classic : `python3 -m pip install clk`

# A quick tour of clk

When you install `clk`, you have access to a full set of awesome
libraries to create your own command line tool, as well as a simple command line
tool called `clk`. You may want to play a bit with the later to grasp the look and
feel of what `clk` is capable of..

First, run `clk --help` or more simply `clk`. See, there are already plenty of
commands already available.

Now you have got a fresh installation of `clk` and have access to the
`clk` command line tool (beware pip install executable files by default in
`~/.local/bin`. Try adding this directory in your PATH in case it is not already
available).

We are first going to try together the `clk` tool so that you can quickly have
an overview of what it is capable of, then we will look into how creating your
own command line tools with the same awesome power.

## Setting up the completion

A great command line tool comes with a great completion support. Run `clk
completion install bash` (or `fish` or `zsh`, your mileage may vary). If you
want to have case-insensitive completion (I do), run it like `clk completion
--case-insensitive install`. `clk` will have added the completion
content into `~/.bash_completion`. It generally needs only to start a new terminal
to have it working. In case of doubt, make sure this file is sourced into your
bashrc file.

## Using the `clk` executable
`clk` is a very practical tool. It allows you to quickly play with
`clk` before starting a real command line application. Everything you
will taste with `clk` will also be available to your own command line
application based on `clk`. You can also (like I do) simply use `clk`
tool to manage your personal « scripts » and take advantage of all the magic of
`clk`, if you don't mind starting all your calls with `clk`.

Because `clk` is the demonstrator and is closely related to `clk`, we
might mention `clk` to say `clk` in the following documentation.

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
cumbersome to add the `--style blue` every time, wouldn't it?

One of the magic of `clk` is the ability to save your default settings. That
way, even if a command comes with sensible defaults, you can always change them
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
`clk` lies in the fact your configuration can be stored in several
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
`clk command path add ~/clk_commands`.

In case you don't want to put your commands in a specific folder, you could also
put the command in the canonical folder of `clk` (`~/.config/clk/bin`).

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
takes one argument (more of this syntax below), named word, of type string with
the documentation `The word to say`. Likewise, `F:--shout/--dont-shout:Shout the
word` indicates a flag whether to shout the word or not.

`clk` is now able to call this command with `clk cowsay@sh`, try first `clk
cowsay@sh --help` to see how the argument was captured by `clk`.

Then, simply run `clk cowsay@sh hello`.

The command is integrated with the magic of `clk`. For instance, you
can call `clk parameters set cowsay@sh --shout` to set the value of shout as
being true by default. To temporary disable the shouting, simply call it with
`--dont-shout`. Of course, it can be part of an alias as well.

#### The parameters micro syntax

As you can see in the example above, you can write the definition of your
parameters (arguments and options) in a way that makes `clk` understand them so
that it can show them correctly in the help.

Let's see together this syntax. For the time being, it is very basic, since we
tend to use python for more complicated use cases, but it might by extended in
the future if use cases appear.

In the help, add a line with nothing but two dashes (`--`. `clk` will try to
parse every line below the two dashes as metadata about the command).

We can define the traditional `click` parameters argument (positional) and
option (referred to using `--OPTION-NAME`).

A line starting with `A:` is an argument: it is a positional parameter. A line
starting with a `O:` is an option: it is referred to with `--option-name
option-value`. A line starting with a `F:` is a flag: a Boolean option. A line
starting with `N:` indicate to let all the remaining arguments through, so that
you can use the traditional `"$@"` construction.

The syntax is
* `A:<name>:<type>:<help>:[<nargs>]`
* `O:<--name>:<type>:<help>:[<default-value>]`
* `F:<--name[/--name-to-disable]>:<help>:[<default-value>]`
* `N:<help>`

The type can be either `str`, `float` or `int`. If it is a string with periods
`.`, it is imported to be used as a subclass of
[ParameterType](https://click.palletsprojects.com/en/7.x/parameters/#parameter-types).
If the type starts with the character `[`, it is considered as the json
representation of a list indicating a choice. For instance
`O:--some-option:["a", "b", "c"]:Some option with 3 choices` will make the
command accept the option `--some-option` with the only valid choices `a`, `b`
and `c`.

#### Other metadata of interest

A line containing only `M:I` indicates `clk` to ignore the unknown options.  A
line starting with `flowdepends: ` indicate the coma separated list of commands
that this command has as flow dependencies.

### Adding a python custom command

Providing a bash script as a command is a very powerful way to take advantage of
the `clk` magic, but if you want to do more than a simple script of a
few lines of code, *write it in python*.

Let's first try to create the python equivalent of the cowsay script.

Decide a location to store the python custom commands and indicate this location
to `clk`. For example, if you want to put your custom python commands
into the folder `~/clk_python`, run `clk command path add --type python
~/clk_python`.

In case you don't want to put your commands in a specific folder, you could also
put the command in the canonical folder of `clk` (`~/.config/clk/python`).

Then, open the file `~/clk_python/cowsay.py` and write the following

```python
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import cowsay as cowsaylib
import click
from click_project.decorators import command, argument, flag, option
from click_project.log import get_logger


LOGGER = get_logger(__name__)


@command()
@argument("word", help="The word to say")
@flag("--shout/--dont-shout", help="Shout the word")
@option("--animal", type=click.Choice(cowsaylib.char_names),
        help="The animal that will speak", default="cow")
def cowsay(word, shout, animal):
    """Let the cow say something"""
    LOGGER.debug("Running the command cowsay")
    if shout:
        word = word.upper() + "!"
    speaker = getattr(cowsaylib, animal)
    speaker(word)
```

Try it with `clk cowsay`

Let's take the opportunity of this first python command to discover that `clk`
provides a logging feature ready to use.

Logging should be easy to read yet provide enough information for debugging for
example. Moreover, the logging should be well separated from other outputs from
the command line tool. In click project, we have created several logging levels
that allows to easily change the log level required for a specific use case, and
the logs are displayed with colors and on the error output by default.

You can see that we created a `LOGGER` object using `LOGGER = get_logger(__name__)`.

This object is a traditional python logger, on which we added a few levels.
1. `LOGGER.develop(message)`, is used to inform of very low level details of clk, you will barely need it.
1. `LOGGER.debug(message)`, is meant to inform about low level details about the command itself, use it to provide extra information in case something is difficult to understand.
1. `LOGGER.action(message)` says what the command does. For instance, it is the level used to inform what happens to the filesystem or what http requests are made.
1. `LOGGER.status(message)` informs of high level steps of the command, like the progress of a download.
1. `LOGGER.deprecated(message)` is useful to indicate deprecated behaviors
1. `LOGGER.info(message)` says general information. It should be the preferred level to communicate general information to the user.
1. `LOGGER.warning(message)` is used to indicate a strange thing that happened that will not prevent the command to finish.
1. `LOGGER.error(message)` indicates something that stopped the command from working.
1. `LOGGER.critical(message)` is about harmful stuff

Like you might expect, enabling a level of log enables all the levels below. The
default log level is `status`, meaning that all logs of levels `status`,
`deprecated`, `info`, `warning`, `error` and `critical` will be shown.

To enable a log level, simply provide it to the call to `clk`, using `clk
--log-level LOGLEVEL`, or more shortly `clk -L LOGLEVEL`. Because the levels
`develop`, `debug` and `action` are often used, they also have shortcuts,
respectively `-D`, `-d` and `-a`.

If, like, us, you like the `action` log level and want to make it the new
default, simply add it to the parameters with `clk parameters set clk -a`.

If you want to see what the log levels look like, you can try them with `clk log
--level MESSAGE`. Of course, you must also enable the associated log level. For
instance, to play with the `develop` level, you would run `clk --log-level
develop log --level develop message`.

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
add "clk cowsay" in front of `COMP_WORDS` and remove its first word (which is
"cs"). Then, the `COMP_CWORD` must be incremented for there is one more word to take
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
way to produce a full-blown command line application. But since several people
do that alias trick, it was worth mentioning how to get the awesome completion
as well.

### Create your project

Let's say that we want to produce a nice command line application with the look
and feel of `clk` and distribute it. We are not up-to-date with all the fancy ways
of creating a project like poetry, so we will stick here with the classical
setuptools way.

For the time being, we don't provide a way to simply create a command line
application without sub commands.

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
        "clk~=0.21.0",
    ],
    entry_points={
        'console_scripts':
        [
            'cowsaycli=cowsaycli.main:main',
        ]
    },
)
```

We opinionated-ly considered the main entry point would be in
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
`clk`, except it won't have the command `git-sync`. This is useful in case you
want to remove some commands of `clk`. Alternatively, you can
use a white list approach setting `include_core_commands` instead of
`exclude_core_commands`, the most extreme case would be `include_core_commands`,
indicating to use none of `clk` commands.

Running `python3 -m pip install -e cowsaycli`, you can have access to the
executable `cowsaycli`, that behaves exactly like `clk`. The instruction
`extra_command_packages=["cowsaycli.commands"]` indicates that every python
module that can be imported as `cowsaycli.commands.<name>` and follows the exact
same convention as custom commands will be considered a sub command of
`cowsaycli`. This is useful, as you just have to populate the folder
`cowsaycli/commands/` with all the commands you like.

For instance, let's copy the `cowsay.py`  file made earlier into this
folder. Great, you now have your own application, called `cowsaycli`, that can be
run like `cowsaycli cowsay --animal cheese test` and that is ready to be
distributed the usual way.

# FAQ
## Why cannot I run my command that needs library X that is installed on my computer?
Most likely you installed clk into a virtualenv, maybe using pipx to install clk.

That is a recommended way of installing things, because virtualenv provide an
isolated python environment. On the other hand, I guess that the library X was
installed not inside the virtualenv, most likely with the traditional `python3
-m pip install X`.

When clk run custom commands, it simply import the python package of the custom
command and run the command. This means that custom commands run in the same
isolated environment as clk itself. The fact that X is not available is in the
consequence that virtualenv mechanism works well.

Yet, this sounds like a sensible question. We suggest that
1. either reinstall clk with `pipx install --system-site-packages clk` for clk to be able to have access to X.
1. or install X directly into the pipx environment with `pipx runpip clk install X`
1. or you can install clk using the traditional `python3 -m pip install clk` command, if installing it and its dependencies outside virtual environment is not that problematic after all
1. or you could install the dependencies of the custom command directly into the virtualenv of clk, by running the dedicated subcommand of clk: `clk pip install X`

Of course, YMMV, and actually we might have forgotten another mean to make clk
get access to X. If you have another idea that you want to share, please tell
us.

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

# Playing with the extensions

Say you have several `parameters` and `aliases` that work together. For
instance, imagine you want to have an alias and a parameter that don't make
sense separately. For instance, add an alias and set its parameters :

`clk alias set hello echo hello` and `clk parameters set hello --style red`

You might want a way to make clear the fact that those two configurations work
together. Enters the extensions.

Create a new extension with `clk extension create hello`.

Then configure the alias and the parameter in the extension with.

`clk alias --extension hello set hello echo hello` and `clk parameters --extension hello set hello --style red`

In case you had configured the alias outside of the extension, run `clk alias unset
hello` and `clk parameters unset hello` to have a better understanding of what
will happen.

Now, run `clk hello` to see it work as before. Run `clk extension disable hello`
and then `clk hello` to see that `clk` complains that the `hello` command is no
more available.

`clk parameters show` and `clk alias show` indeed show nothing about hello.

Then, enable the extension again, with `clk extension enable hello` and take another
look at the parameters and aliases.

The legend indicates that those configurations are in the global/hello level,
which means « the extension hello, defined globally ». Indeed, extensions may be
defined globally or locally and enabled or disabled globally or locally.

Manipulate those two independent dimensions (definition and enabling) may be
tricky. To find out more about the current extensions, run `clk extension show`.

```
extension    set_in    defined_in    link      order
--------  --------  ------------  ------  -------
hello     global    global                   1000
```

Disable it and run the command again.

As you can see, the values did not change, the extension remains defined globally
and set globally (meaning it was disabled globally). Only the color indicate
whether it is disabled or enabled.

Try removing the setting (saying it was enabled or disabled) with `clk extension unset hello`, then see

```
extension    set_in    defined_in    link      order
--------  --------  ------------  ------  -------
hello     Unset     global                   1000
```

Here, the extension is unset, then the default behavior (disabling) is used.

Finally, remove the extension with `clk extension remove hello`.

In conclusion, extensions are a powerful and practical way of grouping several
configuration together to manipulate them as a group.

# Advanced uses of parameters

So far, we have seen the command `clk parameters` to play with the
parameters. But we found out that we generally want to set a parameter once we
have a command line already at hand. For instance, imagine you type for the
third time `clk echo --style blue `, then you realize you should most likely add
a parameter to avoid typing the `--style blue` again and again. With the
`parameters` command, you would have to go back to the beginning of the line and
type `parameters set`. As an alternative, all the command have the option
`--set-parameters` to avoid moving the cursor. In the case of the example, you
could type `clk echo --style blue --set-parameters global`. Likewise, you can
write `clk echo --show-parameters context` to have the equivalent of `clk
parameters show echo`.
