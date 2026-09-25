- [running project scripts](#running-project-scripts)
- [a command that outgrew the project](#a-command-that-outgrew-the-project)
- [a project written by an older clk](#a-project-written-by-an-older-clk)
- [a project written by a newer clk](#a-project-written-by-a-newer-clk)
- [settings you broke by hand](#settings-you-broke-by-hand)
- [a project you name that is not there](#a-project-you-name-that-is-not-there)

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

<pre>
New <span style="color:green;">local</span> alias for somelocalcommand: echo hello
</pre>

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

<pre>
<span style="color:olive;">warning: </span>Failed to get the command somelocalcommand: Command somelocalcommand not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'somelocalcommand'.
error:
error: Did you mean one of these?
error:     command
</pre>

Let's go back in the project and create a parameter.

```bash
cd myprojet
```

```bash
clk parameter set echo hello
clk echo world
```

<pre>
New <span style="color:green;">local</span> parameters for echo: hello
hello world
</pre>

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

Be careful not to use an absolute path with the `project:` prefix. Since `project:` prepends the project root, an absolute path silently overrides it, making the prefix a no-op. clk warns you if this happens.

```bash
clk exec cat project:/tmp/somefile.txt
```

<pre>
<span style="color:olive;">warning: </span>when evaluating project:/tmp/somefile.txt: /tmp/somefile.txt is absolute, prepending project is a noop.
cat: /tmp/somefile.txt: No such file or directory
</pre>


<a id="running-project-scripts"></a>

# running project scripts

Of course, you can create [bash commands](checking_my_server.md) to add logic to your project. But sometimes, projects just have loose scripts lying around in `./scripts` or `./tools` directories. Maybe they were written by someone else, maybe they're legacy, or maybe you just prefer keeping them as plain shell scripts.

You can run them through `clk exec` to give them access to the project context.

Let's create a simple build script in our project.

```bash
mkdir -p scripts
cat <<'EOF' > scripts/build.sh
#!/usr/bin/env bash
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

That walk back up the tree is tedious, and clk spares me it. Every command takes `--in-project`, which runs it at the root of the project and leaves my shell where it was.

```bash
cd src/deep/nested
clk exec --in-project ./scripts/build.sh
```

    Building project at: ./
    App: clk

When I want a particular directory rather than the root, `--cwd` names it. Both together read it from the root of the project.

```bash
clk exec --in-project --cwd scripts ./build.sh
```

    Building project at: ../
    App: clk

When typing `clk exec`, completion suggests both programs from your PATH and executable scripts in the current directory. If you start typing a path like `./`, it switches to file completion to help you navigate to your scripts.

```bash
clk exec ./<TAB>
```

You can also complete deeper paths:

```bash
clk exec ./scripts/b<TAB>
```

The tools your team installed complete as well, since they are on your PATH.

```bash
clk exec run-c<TAB>
```

    run-ci

Since `clk exec` is a regular clk command, you can use it in flows, aliases or add parameters to it. For example, you might have a alias that runs your build script before deploying:

```bash
cat <<'EOF' > scripts/deploy.sh
#!/usr/bin/env bash
echo "Deploying from ${CLK__PROJECT}"
EOF
chmod +x scripts/deploy.sh
```

```bash
clk alias set deploy exec ./scripts/build.sh , exec ./scripts/deploy.sh
```

<pre>
New <span style="color:green;">local</span> alias for deploy: exec ./scripts/build.sh , exec ./scripts/deploy.sh
</pre>

```bash
clk deploy
```

    Building project at: ./
    App: clk
    Deploying from ./


<a id="a-command-that-outgrew-the-project"></a>

# a command that outgrew the project

Some commands start in a project and turn out to be useful everywhere. Here is one, written for this project only.

```bash
clk command create bash release-notes --description "Write the release notes" --body 'echo "gathering the commits since the last tag"'
```

It lives in the project, and only answers there.

```bash
clk command which release-notes
cd .. && clk release-notes 2>&1 | tail -1 ; cd myprojet
```

    ./.clk/bin/release-notes
    error: No such command 'release-notes'.

`clk command move` carries it to the profile you name.

```bash
clk command move release-notes global
clk command which release-notes | sed "s|${TMP}|.|"
cd .. && clk release-notes ; cd myprojet
```

    ./clk-root/bin/release-notes
    gathering the commits since the last tag

Now that it answers everywhere, I want a copy of it back in the project, one I can cut about without touching the real one. `clk command copy` takes the profile to copy into and the name to give it there.

```bash
clk command copy release-notes local release-notes-draft
clk command which release-notes-draft
```

    ./.clk/bin/release-notes-draft

Some days later I forget the draft is there and ask for the copy again. clk stops me rather than write over the work I have been doing.

```bash
clk command copy release-notes local release-notes-draft
```

    Usage: clk command copy [OPTIONS] CUSTOMCOMMAND PROFILE NAME
    error: I won't overwrite ./.clk/bin/release-notes-draft unless explicitly called with --force

When throwing the draft away is what I want, I say so.

```bash
clk command copy release-notes local release-notes-draft --force
clk release-notes-draft
```

    gathering the commits since the last tag


<a id="a-project-written-by-an-older-clk"></a>

# a project written by an older clk

Until version 8, clk kept the settings of a profile in json. A project written back then is migrated the first time you use it, and its settings become json5.

```bash
mkdir -p ../oldproject/.clk
echo 8 > ../oldproject/.clk/version.txt
cat<<'EOF' > ../oldproject/.clk/clk.json
{
    "alias": {
        "hello": {
            "commands": [["echo", "hello"]],
            "documentation": null
        }
    }
}
EOF
```

```bash
cd ../oldproject
clk alias show 2>&1
ls .clk
cd ../myprojet
```

<pre>
<span style="color:olive;">warning: </span>Profile in ./.clk is obsolete. It has the version 8 and current version is 9. Migration started.
hello <span style="color:green;">echo hello</span>
-------------
Legend: <span style="color:green;">local</span>
clk.json5
version.txt
</pre>

Let's take another one whose settings no reader can make sense of, and watch the upgrade give up.

```bash
mkdir -p ../brokenproject/.clk
echo 8 > ../brokenproject/.clk/version.txt
echo '{oops' > ../brokenproject/.clk/clk.json
```

```bash
cd ../brokenproject
clk alias show 2>&1 | tail -2
ls .clk
cd ../myprojet
```

<pre>
<span style="color:red;">error: </span>Expecting property name enclosed in double quotes: line 1 column 2 (char 1)
<span style="color:olive;">warning: </span>The migration of ./.clk did not go well, Restoring backup from ./.clk_backup
clk.json
version.txt
</pre>

A run that died in the middle leaves its backup behind, and the next one will not step over it.

```bash
mkdir -p ../deadrun/.clk ../deadrun/.clk_backup
echo 8 > ../deadrun/.clk/version.txt
cp ../oldproject/.clk/clk.json5 ../deadrun/.clk/clk.json
```

```bash
cd ../deadrun
clk alias show 2>&1 | tail -1
cd ../myprojet
```

<pre>
<span style="color:red;">error: </span>./.clk_backup already exists. Cannot migrate.
</pre>


<a id="a-project-written-by-a-newer-clk"></a>

# a project written by a newer clk

A colleague on a newer clk commits the project. Yours reads the version they left in it.

```bash
echo 99 > .clk/version.txt
```

```bash
clk alias show 2>&1 | head -2
```

    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: The profile at location ./.clk is at version 99. I can only manage till version 9. Please upgrade clk and try again.

Version 8 is old enough that anything before it is no longer supported.

```bash
echo 1 > .clk/version.txt
```

```bash
clk alias show 2>&1 | head -2
```

    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: The profile at location ./.clk is at version 1. I can only migrate profiles from version 8 on. Migrate it manually, or ask for help on https://github.com/clk-project/clk/issues/new .


<a id="settings-you-broke-by-hand"></a>

# settings you broke by hand

Settings are a file like any other, and one day you edit it and leave it in a state no json5 reader can make sense of.

```bash
echo 9 > .clk/version.txt
echo '{parameters: [oops' > .clk/clk.json5
```

clk says so and carries on with nothing, rather than stopping you in your tracks.

```bash
clk alias show 2>&1
```

<pre>
<span style="color:olive;">warning: </span>Can't read settings from ./.clk/clk.json5
</pre>


<a id="a-project-you-name-that-is-not-there"></a>

# a project you name that is not there

You can name the project by hand with `--project`, and one day the one you name has been moved away. clk says so and goes on without it.

```bash
clk --project ../movedaway alias show 2>&1
```

<pre>
<span style="color:red;">critical: </span>../movedaway does not exist. It will be ignored.
</pre>
