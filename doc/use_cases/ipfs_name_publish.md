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
