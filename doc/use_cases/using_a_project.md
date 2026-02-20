- [running project scripts](#running-project-scripts)

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

    warning: Failed to get the command somelocalcommand: Command somelocalcommand not found
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


<a id="running-project-scripts"></a>

# running project scripts

Of course, you can create [bash commands](bash_command.md) to add logic to your project. But sometimes, projects just have loose scripts lying around in `./scripts` or `./tools` directories. Maybe they were written by someone else, maybe they're legacy, or maybe you just prefer keeping them as plain shell scripts.

You can run them through `clk exec` to give them access to the project context.

Let's create a simple build script in our project.

```bash
mkdir -p scripts
cat <<'EOF' > scripts/build.sh
#!/bin/bash
echo "Building project at: ${CLK__PROJECT}"
echo "App: ${CLK_APPNAME}"
EOF
chmod +x scripts/build.sh
```

When you run this script through `clk exec`, it receives environment variables that tell it where the project is located.

```bash
clk exec ./scripts/build.sh
```

    Building project at: ./
    App: clk

This is useful when your script needs to find configuration files or other resources relative to the project root, regardless of which subdirectory you're currently in.

```bash
mkdir -p src/deep/nested
cd src/deep/nested
clk exec ../../../scripts/build.sh
cd ../../..
```

    Building project at: ../../../
    App: clk

When typing `clk exec`, completion suggests both programs from your PATH and executable scripts in the current directory. If you start typing a path like `./`, it switches to file completion to help you navigate to your scripts.

```bash
clk exec ./<TAB>
```

You can also complete deeper paths:

```bash
clk exec ./scripts/b<TAB>
```

Since `clk exec` is a regular clk command, you can use it in flows, aliases or add parameters to it. For example, you might have a alias that runs your build script before deploying:

```bash
cat <<'EOF' > scripts/deploy.sh
#!/bin/bash
echo "Deploying from ${CLK__PROJECT}"
EOF
chmod +x scripts/deploy.sh
```

```bash
clk alias set deploy exec ./scripts/build.sh , exec ./scripts/deploy.sh
```

    New local alias for deploy: exec ./scripts/build.sh , exec ./scripts/deploy.sh

```bash
clk deploy
```

    Building project at: ./
    App: clk
    Deploying from ./
