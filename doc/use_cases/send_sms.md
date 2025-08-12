I like controlling my phone from the comfort of my computer. This includes sending sms. termux provides a way to do so, but the interface is quite low level. Let's try to do better and take advantage of this situation to introduce a more complicated use case of using parameters in bash.

Let's start by mocking the use of termux.

```bash
dumb_contacts='
[
{
    "name": "Martha Thomas",
    "number": "+123456789"
  },
  {
    "name": "Wendy Hodges",
    "number": "+987654321"
  },
  {
    "name": "Kyle Nguyen",
    "number": "+1122334455"
  },
  {
    "name": "Peter Harris",
    "number": "+5566778899"
}
]
'

termux-contact-names () {
    # would call something like ssh myphone termux-contact-list | jq -r '.[].name'
    echo "$dumb_contacts" | jq -r '.[].name'
}

termux-contact-number () {
    local name="$1"
    # would call termux-run termux-contact-list | jq -r ".[] | select(.name == \"${name}\").number"
    echo "$dumb_contacts" | jq -r ".[] | select(.name == \"${name}\").number"
}
```

Let's suppose this code is put under `./lib/termux` in the `bin` folder where the bash commands are put. See [this documentation](bash_command_import.md) for more information about importing libraries.

Now, let's use that library to have a nice completion of contacts

The beginning of the script looks like this<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>:

```bash
#!/bin/bash -eu

source "_clk.sh"

clk_import termux

clk_usage () {
    cat<<EOF
$0

Send a sms to some contacts of mine
--
A:name:$(termux-contact-names|clk_list_to_choice):This contact:{"nargs": -1}
O:--message:str:What to say
EOF
}

clk_help_handler "$@"

```

So far so good, we can create the command termux.smd.send with that content and start seeing the completion with our contacts names appear. Note the `-1` that means we can provide several contacts.

```bash
termux sms send Mart
```

```bash
clk termux sms send Mart<TAB>
```

    Martha Thomas

Now, the contacts provided by clk with `clk_value` (see [that doc](bash_command_use_option.md)) are space separated, but the values already contain spaces.

Let's try running this code for instance directly in the script.

```bash
clk_value name
```

```bash
clk termux sms send "Wendy Hodges" "Kyle Nguyen"
```

    Wendy Hodges Kyle Nguyen

See? There is nothing allowing our script to find out whether we are dealing with one, two three or four names.

I cases where the arguments contain complicated stuffs like that, you can simply get the json representation of them in the special `CLK____JSON` environment variable.

Now, we can do something with them without risking of getting into issues with spaces.

```bash
names () {
    echo "${CLK____JSON}"|jq -r '.name[]'
}
numbers () {
    while read name
    do
        termux-contact-number "${name}"
    done < <(names)
}

numbers="$(numbers|paste -s - -d,)"
echo "ssh myphone termux-sms-send -n \"${numbers}\" \"Hello there!\""
```

Let's try this:

```bash
clk termux sms send "Wendy Hodges" "Kyle Nguyen"
```

    ssh myphone termux-sms-send -n "+987654321,+1122334455" "Hello there!"

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> Read [that doc](bash_command_use_option.md) to find out more about the syntax.
