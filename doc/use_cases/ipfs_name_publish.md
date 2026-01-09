I use ipfs to deal with my files. When I want to share some content, I publish it using ipns.

First, I need to list the keys I have available

Let's mock this by creating a command that lists several arbitrary names.

```bash
clk command create bash ipfs.key.list --description "List the available keys" --body "
cat<<EOF
alice
bob
charly
EOF
"
```

Let's check that we can call it.

```bash
clk ipfs key list
```

    alice
    bob
    charly

Note that I did not have to create the intermediate groups `ipfs` and `ipfs.key`. I simply created the command and clk did the magic for me.

```bash
clk ipfs --help
clk ipfs key --help
```

```
Usage: clk ipfs [OPTIONS] COMMAND [ARGS]...

  Automatically created group to organize subcommands

  This is a built in created group. To remove it, simply remove all its subcommands (with `clk command remove SUBCMD`,
  or `clk alias unset SUBCMD`). To rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename
  SUBCMD`)

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

Commands:
  key  Automatically created group to organize subcommands
Usage: clk ipfs key [OPTIONS] COMMAND [ARGS]...

  Automatically created group to organize subcommands

  This is a built in created group. To remove it, simply remove all its subcommands (with `clk command remove SUBCMD`,
  or `clk alias unset SUBCMD`). To rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename
  SUBCMD`)

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

Commands:
  list  List the available keys
```

Now, I want to have a command that uses this content as possible values for a key argument. Therefore, I create another command at the path ipfs.name.publish with the following content.

```bash
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Publish another cid to the given key id
--
A:cid:str:The cid to Publish
A:key:$(clk ipfs key list|clk_list_to_choice):The key to publish to
EOF
}

clk_help_handler "$@"
# here, I simply echo because this is a mock command
echo "ipfs name publish --key=$(clk_value key) $(clk_value cid)"
```

Now, I can try using the completion of this command.

```bash
clk ipfs name publish somecontent al<TAB>
```

    alice

And I can simply call it

```bash
clk ipfs name publish somecid alice
```

    ipfs name publish --key=alice somecid
