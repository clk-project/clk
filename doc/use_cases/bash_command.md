To create a bash command, you can simply call the following command.

```bash
clk command create bash mycommand --no-open
```

Note that if you omit the no open, your editor will be used to first edit the command.

```bash
clk command which mycommand
```

    /home/sam/tmp/tmp.V6TskPmMKR-clk-test/clk-root/bin/mycommand

```bash
clk mycommand
```

    [33mwarning: [0mThe command 'mycommand' has no documentation

It does not do much, but it is now part of your tools

```bash
clk | grep mycommand
```

    mycommand   Description

Now, let's put something into this command

```bash
cat <<"EOH" > "$(clk command which mycommand)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

This command shows something
--

EOF
}

clk_help_handler "$@"

echo something

EOH
```

```bash
clk mycommand --help
```

    Usage: clk mycommand [OPTIONS]
    
      This command shows something blablabla
    
      The current parameters set for this command are: --help
    
    Options:
      --help-all  Show the full help message, automatic options included.
      --help      Show this message and exit.

```bash
test "$(clk mycommand)" = "something"
```