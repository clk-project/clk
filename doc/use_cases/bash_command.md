To create a bash command, you can simply call the following command.

```bash
clk command create bash mycommand
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
  --context              Guess the profile  [default: False]
  --global               Consider only the global profile  [default: False]
  --help                 Show this message and exit.

Commands:
  bash       Create a bash custom command
  from-file  Install the given file as a customcommand, infering its type.
  python     Create a bash custom command
```

Let's look at this file together.

```bash
cat $(clk command which mycommand)
```

```
#!/bin/bash -eu

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

Below the `--` line, you will write the descriptions of the arguments and options (see [the dedicated tutorial](bash_command_use_option.md)).

If you keep the word `Description` in the help message, clk will warn you that you should replace it with something more interesting.

```bash
clk mycommand
```

    warning: The command 'mycommand' has no documentation

Let's write something in here.

```bash
sed -i 's/Description/Command that says something/g' "$(clk command which mycommand)"
```

```bash
clk mycommand --help|sed "s|$(pwd)|.|"
```

```
Usage: clk mycommand [OPTIONS]

  Command that says something

  Edit this external command by running `clk command edit mycommand`
  Or edit ./clk-root/bin/mycommand directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.
```

The last part `clk_help_handler "$@"` is the glue code that makes clk parse the command line. After this line, you can write the content of your command line.

Let's make this command say something.

```bash
cat<<EOF >> "$(clk command which mycommand)"
echo something
EOF
```

```bash
clk mycommand
```

    something

clk will try hard to respect the exit code of the bash command.

Let's assume for instance that you created a command that simply exits with the code 5.

```bash
clk command create bash --body "exit 5" --description "Simply exiting with the code 5" exit5
```

Then, let's call it and check its exit code.

```bash
clk exit5 || echo $?
```

    5

Additionally, you can put whatever traps you want in your code and clk will try to respect them.

```bash
  clk command create bash --body "
  clean () {
echo 'cleaning'
}
trap clean EXIT
echo 'starting'
sleep 3600
  " --description "Simply wait but clean before exiting" clean-test
```

```bash
clk clean-test
```

When starting this command and then killing it with Ctrl-C, you will get.

    starting
    ^Ccleaning


    Aborted!
