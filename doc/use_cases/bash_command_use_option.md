- [completing against files](#dddf6c5e-3fce-4203-b75c-e918bcf3240f)
- [passing a URL to a file argument](#6a1b2c3d-4e5f-6789-abcd-ef0123456789)
- [giving the defaults in json](#giving-the-defaults-in-json)

An option is an optional parameter that is given a value. A flag is an optional parameter that is a boolean. An argument is a positional parameter that you must give.

```bash
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A kind of animal:{"default": "duck", "nargs": 1}
O:--sound-of-animal:str:The sound the animal makes
O:--repeat:int:How many times to repeat the message:{"default": 0}
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

for i in $(seq 1 "${CLK___REPEAT}")
do
    echo "${msg}"
done
```

```bash
clk command create bash animal --no-open
cat <<"EOH" > "$(clk command which animal)"
#!/usr/bin/env bash
  set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

This command shows something
--
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A kind of animal:{"default": "duck", "nargs": 1}
O:--sound-of-animal:str:The sound the animal makes
O:--repeat:int:How many times to repeat the message:{"default": 0}
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

for i in $(seq 1 "${CLK___REPEAT}")
do
    echo "${msg}"
done

EOH
```

We can see the help of those parameters in the help of the command.

```bash
clk animal --help | grep -- 'A kind of animal'
clk animal --help | grep -- '--sound-of-animal'
clk animal --help | grep -- '--repeat'
clk animal --help | grep -- '--shout'
```

    [duck|whale|cat|dog]  A kind of animal  [default: duck]
    --sound-of-animal TEXT  The sound the animal makes
    --repeat INTEGER        How many times to repeat the message  [default: 0]
    --shout                 Print the message of the animal in capital case

Passing `--help-all` additionally reveals the automatic options every clk command carries, whichever way it was written.

```bash
clk animal --help-all | grep -- '--in-project / --no-in-project'
```

    --in-project / --no-in-project  Run the command in the project directory  [default: no-in-project]


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
#!/usr/bin/env bash
  set -eu

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
      [DOCUMENT]  The document to count words in

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

All of that needs your shell to know about clk. `clk completion show` prints the code that teaches it.

```bash
clk completion show | head -6
```

    _clk_completion() {
        local IFS=$'\n'
        local response

        response=$(env COMP_WORDS="${COMP_WORDS[*]}" COMP_CWORD=$COMP_CWORD _CLK_COMPLETE=bash_complete $1)

`clk completion install` writes it in `~/.bash_completion`, where your shell reads it when it starts.

```bash
clk completion install
```

Type the name in the wrong case though, and nothing comes back.

```bash
clk wordcount TE<TAB>
```

Install the completion telling it to ignore the case.

```bash
clk completion --case-insensitive install
```

The same key now finds the file.

```bash
clk wordcount TE<TAB>
```

    ./testfile.txt


<a id="6a1b2c3d-4e5f-6789-abcd-ef0123456789"></a>

# passing a URL to a file argument

Sometimes, a command argument declared with the `file` type may also accept a URL. For instance, a command that installs a package might accept either a local file path or a URL to download from.

```bash
A:package:file:Package to install
```

```bash
echo "$(clk_value package)"
```

When passing a URL, the value should be preserved as-is, without being resolved as a file path.

```bash
clk showpackage https://example.com/path/to/package.apk
```

    https://example.com/path/to/package.apk


<a id="giving-the-defaults-in-json"></a>

# giving the defaults in json

A command I wrote a while ago gives the defaults of its option and of its flag after a colon.

```bash
O:--times:int:How many times to greet:1
F:--loud/--quiet:Greet in capital case:True
```

clk still reads them, and tells me how to write them now.

```bash
clk greet
```

<pre>
<span style="color:purple;">deprecated: </span>In greet, O:--times:int:How many times to greet:1 gives its default after a colon. Give it in the json that ends the line instead, like O:name:type:help:{&quot;default&quot;: &quot;value&quot;}
<span style="color:purple;">deprecated: </span>In greet, F:--loud/--quiet:Greet in capital case:True gives its default after a colon. Give it in the json that ends the line instead, like F:name:help:{&quot;default&quot;: true}
HELLO
</pre>

A default that holds colons, like a url, would not fit after a colon anyway. The json that ends the line takes any default.

```bash
clk command create bash greet --force --description "Greet someone" \
    --option '--times:int:How many times to greet:{"default": 1}' \
    --flag '--loud/--quiet:Greet in capital case:{"default": true}' \
    --body '
msg=hello
if clk_true loud
then
    msg=HELLO
fi
for i in $(seq 1 "${CLK___TIMES}")
do
    echo "${msg}"
done
'
```

```bash
clk greet --times 2
```

    HELLO
    HELLO

When I forget the help of an option, clk tells me what it expected.

```bash
clk command create bash typo --option '--times:int'
clk typo
```

<pre>
<span style="color:olive;">warning: </span>When loading command typo at path ./clk-root/bin/typo: Expected format in typo is O:name:type:help[:{someextrajsondata}], got O:--times:int
<span style="color:red;">error: </span>Found the command typo in the resolver external but could not load it.
<span style="color:olive;">warning: </span>Failed to get the command typo: Expected format in typo is O:name:type:help[:{someextrajsondata}], got O:--times:int
error: clk.typo could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error
</pre>

The same goes for a flag.

```bash
clk command create bash typo --force --flag '--loud'
clk typo
```

<pre>
<span style="color:olive;">warning: </span>When loading command typo at path ./clk-root/bin/typo: Expected format in typo is F:name:help[:{someextrajsondata}], got F:--loud
<span style="color:red;">error: </span>Found the command typo in the resolver external but could not load it.
<span style="color:olive;">warning: </span>Failed to get the command typo: Expected format in typo is F:name:help[:{someextrajsondata}], got F:--loud
error: clk.typo could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error
</pre>
