An option is an optional parameter that is given a value. A flag is an optional parameter that is a boolean. An argument is a positional parameter that you must give.

```bash
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A kind of animal:{"default": "duck", "nargs": 1}
O:--sound-of-animal:str:The sound the animal makes
F:--shout:Print the message of the animal in capital case
```

```bash
if clk_given sound-of-animal
then
    msg="$(clk_value kind-of-animal) does $(clk_value sound-of-animal)"
else
    msg="I don't know what sound ${CLK___KIND_OF_ANIMAL} makes"
fi

if clk_true shout
then
    echo "${msg}"|tr '[:lower:]' '[:upper:]'
else
    echo "${msg}"
fi
```

```bash
clk command create bash animal --no-open
cat <<"EOH" > "$(clk command which animal)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

This command shows something
--
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A kind of animal:{"default": "duck", "nargs": 1}
O:--sound-of-animal:str:The sound the animal makes
F:--shout:Print the message of the animal in capital case
EOF
}

clk_help_handler "$@"

if clk_given sound-of-animal
then
    msg="$(clk_value kind-of-animal) does $(clk_value sound-of-animal)"
else
    msg="I don't know what sound ${CLK___KIND_OF_ANIMAL} makes"
fi

if clk_true shout
then
    echo "${msg}"|tr '[:lower:]' '[:upper:]'
else
    echo "${msg}"
fi

EOH
```

We can see the help of those parameters in the help of the command.

```bash
clk animal --help | grep -- 'KIND_OF_ANIMAL'
clk animal --help | grep -- '--sound-of-animal'
clk animal --help | grep -- '--shout'
```

    KIND_OF_ANIMAL [duck|whale|cat|dog]
    --sound-of-animal TEXT  The sound the animal makes
    --shout                 Print the message of the animal in capital case  [default:

```bash
clk animal 2>&1 > /dev/null | grep "Missing argument 'KIND_OF_ANIMAL'"
```

```bash
test "$(clk animal duck --sound-of-animal couac)" = "duck does couac"
test "$(clk animal --sound-of-animal couac)" = "duck does couac"
test "$(clk animal whale --shout)" = "I DON'T KNOW WHAT SOUND WHALE MAKES"
```
