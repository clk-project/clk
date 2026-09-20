- [making the check a command](#making-the-check-a-command)
- [saying what it does](#saying-what-it-does)
- [the exit code my scripts read](#the-exit-code-my-scripts-read)
- [when I stop it in the middle](#when-i-stop-it-in-the-middle)
- [giving it the host to ask](#giving-it-the-host-to-ask)
- [when I break it](#when-i-break-it)

I host a few things at home and I like knowing that they answer. I always end up typing the same curl, reading the same output and forgetting what the exit code meant. Let's make a command out of it, and take advantage of this situation to see what clk does with the exit codes and the interruptions on the way.


<a id="making-the-check-a-command"></a>

# making the check a command

To create a bash command, you can simply call the following command.

```bash
clk command create bash server.check
```

Your editor will be used to first edit the command. This command will already contain some code to get you started.

Note that you can always get the help of any command using `--help`. So don't hesitate to try.

```bash
clk command create --help
```

```
Usage: clk command create [OPTIONS] COMMAND [ARGS]...

  Create custom commands directly from the command line.

  This is a built-in command.

Options:
  --help-all             Show the full help message, automatic options included.
  --extension EXTENSION  Use this extension
  --context              Guess the profile
  --global               Consider only the global profile
  --help                 Show this message and exit.

Commands:
  bash    Create a bash custom command
  python  Create a bash custom command
```

Let's look at this file together.

```bash
cat $(clk command which server.check)
```

```
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Description
--

EOF
}

clk_help_handler "$@"
```

The first part, `source "_clk.sh"` loads a few helpers provided by clk to make your life easier. Among other things, it contains the glue code to make clk parse your command line.

Then, `clk_usage` is responsible to provide the help message and the description of the options and arguments.

On top of the line with two dashes `--` , you write whatever plain text content you want. It will be available in the `--help` output.

Below the `--` line, you will write the descriptions of the arguments and options.

If you keep the word `Description` in the help message, clk will warn you that you should replace it with something more interesting.

```bash
clk server check
```

    warning: The command 'server.check' has no documentation


<a id="saying-what-it-does"></a>

# saying what it does

Let's write something in here. You can edit the file directly using `clk command edit`.

```bash
clk command edit server.check
```

For the sake of this tutorial, we will provide a custom `EDITOR` that automatically makes the change.

```bash
cat<<'EOF' > myeditor
#!/usr/bin/env bash
  set -eu
sed -i 's/Description/Say whether my server answers/g' "${1}"
EOF
chmod +x myeditor
VISUAL=./myeditor clk command edit server.check
```

```bash
clk server check --help|sed "s|$(pwd)|.|"
```

```
Usage: clk server check [OPTIONS]

  Say whether my server answers

  Edit this external command by running `clk command edit server.check`
  Or edit ./clk-root/bin/server.check directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.
```

The last part `clk_help_handler "$@"` is the glue code that makes clk parse the command line. After this line, you can write the content of your command line.

Here, the server is down and curl says so with its own exit code, 7.

```bash
cat<<EOF >> "$(clk command which server.check)"
echo "no answer from myserver"
exit 7
EOF
```

```bash
clk server check
```

    no answer from myserver


<a id="the-exit-code-my-scripts-read"></a>

# the exit code my scripts read

clk will try hard to respect the exit code of the bash command, so that whatever calls this check learns what curl had to say.

```bash
clk server check || echo $?
```

    no answer from myserver
    7


<a id="when-i-stop-it-in-the-middle"></a>

# when I stop it in the middle

Watching the server rather than asking it once means opening a tunnel and keeping it open. Whatever I do next, that tunnel has to go, so the command puts it in a trap, and clk will try to respect it.

```bash
  clk command create bash --body "
  close_tunnel () {
echo 'closing the tunnel'
}
trap close_tunnel EXIT
echo 'watching the server'
sleep 3600
  " --description "Watch the server through a tunnel" server.watch
```

```bash
clk server watch
```

Hitting Ctrl-C gives.

    watching the server
    ^Cclosing the tunnel


    Aborted!


<a id="giving-it-the-host-to-ask"></a>

# giving it the host to ask

One server became three, so the check takes the host to ask. The lines under the `--` have a shape, and the day I wrote that one too short, clk said which shape it wanted.

```bash
check="$(clk command which server.check)"
cat<<'EOF' > "${check}"
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOS
$0

Say whether my server answers
--
A:host
EOS
}

clk_help_handler "$@"

echo "no answer from ${CLK___HOST}"
EOF
```

```bash
clk server check myserver 2>&1 | head -1
```

    warning: When loading command server.check at path ./clk-root/bin/server.check: Expected format in server.check is A:name:type:help[:{someextrajsondata}], got A:host

A type and a help later, the host gets through.

```bash
sed -i 's/^A:host$/A:host:str:The server to ask/' "${check}"
```

```bash
clk server check myserver
```

    no answer from myserver


<a id="when-i-break-it"></a>

# when I break it

A command whose `--help` does not answer at all is not hidden either: it is shown, and said to be broken.

```bash
cat<<'EOF' > "${check}"
#!/usr/bin/env bash
exit 1
EOF
```

```bash
clk server check --help | head -3
```

    Usage: clk server check [OPTIONS]

      No help found... (the command is most likely broken)
