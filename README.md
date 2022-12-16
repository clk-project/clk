[clk](https://clk-project.org/)
==============================================================================
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_index)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=bugs)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=code_smells)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=ncloc)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=duplicated_lines_density)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=coverage)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=security_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=alert_status)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![CircleCI](https://circleci.com/gh/clk-project/clk.svg?style=svg)](https://app.circleci.com/pipelines/github/clk-project/clk)

Come and discuss clk with us on
- [![IRC libera.chat #clk](https://raster.shields.io/badge/libera.chat-%23clk-blue)](https://web.libera.chat/?channels=#clk)
- [![Gitter](https://badges.gitter.im/clk-project/community.svg)](https://gitter.im/clk-project/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

clk (*Command Line Kit*) is a program that provides nothing but the features of
a (in our opinionated minds) wonderful command line tool. On top of it, you create
your own commands to build your own tool.

Among other things, it provides out of the box:

- great completion support
- aliases
- persistence of options and arguments
- commands flow management
- launchers
- and more...


You may create several atomic commands and use clk features (alias, parameter,
flow) to end up with higher level commands that capture whatever complicated
workflow you might want to do.

In the end, calling you high level commands should only require you to type a
few words, not very long lines with several long options.

What we think is no easy to remember:
```sh
# complicated chains of command to "do-something"
command1 --some-flag --some-option some-value && command2 --some-other-option some-other-value
```

People often realize that those need to be memorized and tend to put them in
text notes or documentations, in shell scripts or in shell history handling
ninja tricks. In a sense, they acknowledge this is not something that should
waste their cognitive load.

We believe that clk helps capture those workflows in a more usable way.

What we think should be more appropriate:
```sh
# you only have to remember you want do "do-something"
clk do-something
```

This aspect of helping you removing the cognitive load of remembering how to
call a complicated command line tool is why clk is also named a *Cognitive Load
Killer*: you can focus on what you want to get done instead of how to how to ask
the tool to do it.

This cognitive load is specific to each individual. For example, if you find out
that for your brain, it is easier to remember to "do-some-other-thing" rather
than "do-something", we encourage you to capture this as well.

```sh
clk alias set do-some-other-thing do-something
# now, you can only remember to "do-some-other-thing" while your team mates can still "do-something"
clk do-some-other-thing  # will behave exactly like "clk do-something"
```

You might also think that it makes more sense to you to do something
differently. This should also be captured.

```sh
clk parameter set do-something --in-some-way
# now, you can only remember to "do-something"
clk do-something  # will behave exactly like "clk do-something --in-some-way"
clk do-some-other-thing  # will behave exactly like "clk do-something --in-some-way"
```

Those can be combined in case you remember "do something with some specifics" as "do-some-other-thing"

```sh
clk parameter set do-some-other-thing --with-some-specifics
# now, you can only remember to "do-something"
clk do-something  # will behave exactly like "clk do-something --in-some-way"
# or to "do-some-other-thing"
clk do-some-other-thing  # will behave exactly like "clk do-something --in-some-way --with-some-specifics"
```

See the WIP documentation of the lib [here](./doc/lib.html).

And some attempt at showing uses cases [here](./doc/use_cases).

# Installation

You need to have python3. On debian based system, due to a [bug in the packaging
of python3](https://github.com/pypa/get-pip/issues/124), you also need to
install python3-distutils. This can simply be done with `sudo apt install
python3-distutils`.

Install with `curl -sSL https://clk-project.org/install.sh | bash`
or `python3 -m pip install clk`

Now, the `clk` tool is available in `~/.local/bin/`, if that directory is not
already in your path, use `export PATH="${PATH}:${HOME}/.local/bin"`

# Getting used of the tool

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

Actually because `clk` simply provides features on top of
[click](https://click.palletsprojects.com/), please take a look at click's
documentation to understand how to write commands.

Close your editor, make sure the cowsay dependency is available `python3 -m pip install cowsay`.

And now, try:

`clk say --help`

`clk say hello`

You have created your first command!

You can see that this command already provides a nice help message.

You could have created a click command that does exactly that, without using
`clk`. So you might wonder why using clk in the first place. But now, this
command can take advantage of all the features that come with clk.

For instance, you can create aliases:

Let's create an alias called `hello` that runs the command `say` (the one you just created) with the argument `hello world`

`clk alias set hello say hello world`

And you have created another command, `hello`, that says hello. Try it with.

`clk hello`

This feature allows you to provide generic commands with a lot of power and let
your users customize those commands to fit per particular needs.

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


# A quick tour of clk

## Using the `clk` executable
`clk` is a very practical tool. It allows you to quickly play with
`clk` before starting a real command line application. Everything you
will taste with `clk` will also be available to your own command line
application based on `clk`. You can also (like I do) simply use `clk`
tool to manage your personal « scripts » and take advantage of all the magic of
`clk`, if you don't mind starting all your calls with `clk`.

Because `clk` is the demonstrator and is closely related to `clk`, we
might mention `clk` to say `clk` in the following documentation.

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
