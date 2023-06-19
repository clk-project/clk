To create a bash command, you can simply call the following command.

```bash
clk command create bash mycommand
```

Your editor will be used to first edit the command. This command will already contain some code to get you started.

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
clk mycommand --help
```

    Usage: clk mycommand [OPTIONS]
    
      Command that says something
    
    Options:
      --help-all  Show the full help message, automatic options included.
      --help      Show this message and exit.

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