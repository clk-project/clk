When working in project, it is useful to have a way to tell where the root of the project is.

In git, the folder `.git` tells where the root of the project is. In clk, it is the folder `.clk`.

We don't actually have a command to create a project. The mere existence of this directory is enough.

```bash
mkdir myprojet && cd myprojet && mkdir .clk
```

From here, most of the commands (aliases, parameters) you use that deal with persisting information will put that data in this project rather than in the global configuration.

For example, let's create a local alias.

```bash
clk alias set somelocalcommand echo hello
```

    New local alias for somelocalcommand: echo hello

You can call this alias when inside the project.

```bash
clk somelocalcommand
```

    hello

But, once getting out of the project, the command vanishes.

```bash
cd ..
```

```bash
clk somelocalcommand
```

    Usage: clk [OPTIONS] COMMAND [ARGS]...
    error: No such command 'somelocalcommand'.
    error:
    error: Did you mean one of these?
    error:     command

Let's go back in the project and create a parameter.

```bash
cd myprojet
```

```bash
clk parameter set echo hello
clk echo world
```

    New local parameters for echo: hello
    hello world

This parameter is also unavailable only inside the project.

```bash
cd .. && clk echo world
cd myprojet && clk echo world
```

    world
    hello world

You can reference files inside the project using the `project:` prefix.

```bash
echo somecontent > somefile.txt
clk exec cat project:somefile.txt
```

    somecontent