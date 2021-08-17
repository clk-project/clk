#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import group, option
from clk.lib import ParameterType


@group(default_command='intro')
def learn():
    """The commands to learn the concepts and tooling around clk"""


@learn.command()
def intro():
    """Introduction"""
    print("""Hi and welcome to the commands that will help you learn clk.

clk comes with a lot of commands by default. Don't be afraid, we have the time
to see them and understand how they work together to give you an incredibly nice
command line experience.

I suggest you start playing with the completion with `clk learn completion`.
""")


class TrymeType(ParameterType):
    name = 'TryMe'

    def complete(self, ctx, incomplete):
        return ['you_got_it']


@learn.command()
@option('--try-me', type=TrymeType(), help='An option to try the completion')
def completion(try_me):
    """Let's learn the completion together"""
    if try_me == 'you_got_it':
        print("""Awesome, you got the completion working!

I suggest you try the exec command next.

`clk learn exec`
""")
    else:
        print("""The first thing you should be looking for in a command line interface
is the completion.

You can setup the completion for clk by running the command:

`clk completion install <your_shell>`

You might need to log out and log in again for the completion to start working.

Then, try completing the option in:

`clk learn completion --try-me <TAB>`

And run the command again.

Or, if you don't want to bother with the completion, continue your journey with
the printing stuff.

`clk learn printing`
            """)


@learn.command()
def printing():
    """Start printing something"""
    print("""In a good command line tool, you need to have a powerful logging
system.

clk comes with one of those.

Try running

`clk log test` to see the message test on your terminal. All the logging happens
in stderr to avoid polluting stdout, reserved for inter process communication.

You have access to several logging levels: develop, debug, action, status,
deprecated, info, status, warning, error, critical

The default log level is info, but you can use another one with the --level
(or the short version -l) command line option.

Try for instance `clk log --level critical test` and see that each level has its
own color.

Another command to print is echo.

Try for instance `clk echo test`. You might think that this is the same as `clk
log test` but in fact echo writes in the stdout and is meant to provide
information parsed by other command line tools.

Now that you know out to print stuff, continue your journey with

`clk learn exec`
""")


@learn.command()
def exec():
    """Learn the exec command"""
    print("""clk by itself only provide command line tools features. Now, we start playing
with the most basic way to make it interact with some external stuff to create
your own tooling.

Say you need to run print the content of a file, you would write `cat
<myfile>`.

Now try running `clk exec cat <myfile>` to do the same thing.

You most likely wonder why I make you run a three words command `clk exec cat`
while `cat` was enough. This is normal and it will make sense when you have
understood aliases and parameters.

By the way, the next stuff to learn is

`clk learn alias`
""")


@learn.command()
def alias():
    """Alias"""
    print("""This is the first real feature of clk.

An alias is basically a shortcut to run another command.

You have learned to print stuff in the command line and executing external
commands.

For instance, you learned to run `clk exec cat <myfile>`.

Now, imagine that one of the feature you want from your command line tool is to
cat a file. Let's create the alias that runs cat from clk.

`clk alias set readfile exec cat`

This basically means: "Create a command readfile that behave exactly like the
command `exec cat`"

Then you can run it with

`clk readfile <myfile>`

It looks like nothing, but doing so, you created your first command in clk. You
will be able to use it with the other features that we will see later.

You can see the aliases with `clk alias show` and you can remove it with `clk
alias unset readfile`. I suggest you put it back because I will use it later in
the learning commands.

Continue your journey with

`clk learn parameter`
  """)


@learn.command()
def parameter():
    """Configuring commands"""
    print("""You created your first command `readfile`.

Let's say you want the command readfile to show the line number of the file. You
know that cat accepts the option -n to do so.

You could have defined readfile to
""")
