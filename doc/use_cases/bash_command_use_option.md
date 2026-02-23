- [completing against files](#dddf6c5e-3fce-4203-b75c-e918bcf3240f)

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
    --sound-of-animal TEXT  The sound the animal makes  [default: None]
    --shout                 Print the message of the animal in capital case  [default: False]


<a id="dddf6c5e-3fce-4203-b75c-e918bcf3240f"></a>

# completing against files

Sometimes, your command takes a file as input. For instance, let's say you want a command that counts the words in a document.

You want pressing `<TAB>` on the argument to suggest files from the current directory, just like `cat` or `ls` would. To get this, use the `file` type.

```bash
A:document:file:The document to count words in
```

```bash
clk command create bash wordcount
cat <<"EOH" > "$(clk command which wordcount)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Count the words in a document
--
A:document:file:The document to count words in
EOF
}

clk_help_handler "$@"

wc -w < "$(clk_value document)"

EOH
```

```bash
clk wordcount --help | grep DOCUMENT
```

    Usage: clk wordcount [OPTIONS] [DOCUMENT]
      DOCUMENT  The document to count words in  [default: None]

Let's try it.

```bash
echo "one two three four five" > testfile.txt
```

```bash
clk wordcount testfile.txt
```

    5

And completion suggests files from the current directory.

```bash
clk wordcount te<TAB>
```

    ./testfile.txt

The `file` type works the same way for options. For instance, if you had written `O:--document:file:The document to count words in` instead, pressing `<TAB>` after `--document` would also suggest files.
