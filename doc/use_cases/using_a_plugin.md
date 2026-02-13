- [installing a plugin](#installing-a-plugin)
- [the trigger plugin code](#the-trigger-plugin-code)
- [using triggers](#using-triggers)
  - [setting and showing a trigger](#setting-and-showing-a-trigger)
  - [pre-trigger execution](#pre-trigger-execution)
  - [success triggers](#success-triggers)
  - [unsetting a trigger](#unsetting-a-trigger)
  - [listing triggers with &#x2013;name-only](#listing-triggers-name-only)

In the past, clk contained a command used to add hooks before and after other commands. This was highly advanced stuff and eventually was barely used. It was removed from clk. But, with the plugin mechanism, you actually can put this feature back into clk.


<a id="installing-a-plugin"></a>

# installing a plugin

To install a plugin in clk, you need to place the plugin file in the `plugins` directory of your clk configuration folder. By default, this is `~/.config/clk/plugins/`.

For example, to install the trigger plugin shown below, you would:

1.  Create the plugins directory if it doesn't exist:

```bash
mkdir -p ~/.config/clk/plugins
```

1.  Copy or create the plugin file:

```bash
cp myplugin.py ~/.config/clk/plugins/
```

The plugin will be automatically loaded the next time you run clk.

Note that plugins must have a `load_plugin()` function that will be called when clk loads them. This function is responsible for initializing the plugin, registering commands, and performing any necessary setup.

Let's test this with the trigger plugin.


<a id="the-trigger-plugin-code"></a>

# the trigger plugin code

The plugin is kept in clk repository.

To install it try something like:

```bash
mkdir -p ~/.config/clk/plugins
wget -O ~/.config/clk/plugins/trigger.py \
  https://raw.githubusercontent.com/clk-project/clk/main/contrib/plugin/trigger.py
```

Once copied in the plugin directory, you should be able to see it listed in the list of plugins&#x2026;

```bash
clk plugin show
```

    trigger Trigger plugin - run commands before/after other commands.

&#x2026;and use the injected command like any other.

```bash
clk trigger --help | head -15
```

```
Usage: clk trigger [OPTIONS] COMMAND [ARGS]...

  Manipulate command triggers.

  Triggers allow you to automatically run commands before or after other commands. This is useful for working around
  issues in tools or adding consistent behaviors.

  To run command B before command A:

      clk trigger set pre A B

  To run command B only after successful execution of A:

      clk trigger set success A B
```


<a id="using-triggers"></a>

# using triggers

Now that the plugin is installed, let's explore how to use triggers effectively. Triggers allow you to automatically run commands before or after other commands, which is useful for adding consistent behaviors or working around issues in tools.


<a id="setting-and-showing-a-trigger"></a>

## setting and showing a trigger

Let's start by creating a simple command and setting a pre-trigger on it. First, we'll create an alias that we can attach a trigger to:

```bash
clk alias set mycommand echo 'main command'
```

Now let's set a pre-trigger that will run before `mycommand`:

```bash
clk trigger set pre mycommand echo hello
```

We can verify that the trigger was set by showing it:

```bash
clk trigger show --no-color pre mycommand
```

    mycommand echo hello


<a id="pre-trigger-execution"></a>

## pre-trigger execution

When we run `mycommand`, the pre-trigger executes first, followed by the main command:

```bash
clk mycommand
```

    hello
    main command

As you can see, "hello" appears before "main command", demonstrating that the pre-trigger runs before the actual command.


<a id="success-triggers"></a>

## success triggers

You can also set triggers that only run after a command succeeds. Let's create a new command and add a success trigger:

```bash
clk alias set buildcmd echo 'build complete'
clk trigger set success buildcmd echo 'after success'
```

```bash
clk buildcmd
```

    build complete
    after success


<a id="unsetting-a-trigger"></a>

## unsetting a trigger

To remove a trigger, use the `unset` command:

```bash
clk trigger unset pre mycommand
```

After unsetting, only the main command runs:

```bash
clk mycommand
```

    main command


<a id="listing-triggers-name-only"></a>

## listing triggers with &#x2013;name-only

When you have many triggers, you can list just the command names that have triggers:

```bash
clk alias set cmd1 echo 'one'
clk alias set cmd2 echo 'two'
clk trigger set pre cmd1 echo 'trigger1'
clk trigger set pre cmd2 echo 'trigger2'
```

```bash
clk trigger show pre --name-only
```

    buildcmd
    cmd1
    cmd2
