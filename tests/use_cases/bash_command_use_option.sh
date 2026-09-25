#!/usr/bin/env bash
# [[file:../../doc/use_cases/bash_command_use_option.org::#giving-the-defaults-in-json][giving the defaults in json:7]]
set -eu
. ./sandboxing.sh

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


see_code () {
      clk animal --help | grep -- 'A kind of animal'
      clk animal --help | grep -- '--sound-of-animal'
      clk animal --help | grep -- '--repeat'
      clk animal --help | grep -- '--shout'
}

see_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  [duck|whale|cat|dog]  A kind of animal  [default: duck]
  --sound-of-animal TEXT  The sound the animal makes
  --repeat INTEGER        How many times to repeat the message  [default: 0]
  --shout                 Print the message of the animal in capital case
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run see'

{ see_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/see"
else
    see_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying see"
        exit 1
    }
fi



see-help-all_code () {
      clk animal --help-all | grep -- '--in-project / --no-in-project'
}

see-help-all_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  --in-project / --no-in-project  Run the command in the project directory  [default: no-in-project]
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run see-help-all'

{ see-help-all_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/see-help-all"
else
    see-help-all_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying see-help-all"
        exit 1
    }
fi


test "$(clk animal duck --sound-of-animal couac)" = "duck does couac"
test "$(clk animal --sound-of-animal couac)" = "duck does couac"
test "$(clk animal whale --shout)" = "I DON'T KNOW WHAT SOUND WHALE MAKES"
test "$(clk animal duck --sound-of-animal couac --repeat 0)" = "duck does couac"
test "$(clk animal duck --sound-of-animal couac --repeat 2)" = "duck does couac
duck does couac
duck does couac"

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


wordcount-help_code () {
      clk wordcount --help | grep DOCUMENT
}

wordcount-help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk wordcount [OPTIONS] [DOCUMENT]
  [DOCUMENT]  The document to count words in
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run wordcount-help'

{ wordcount-help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/wordcount-help"
else
    wordcount-help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying wordcount-help"
        exit 1
    }
fi


echo "one two three four five" > testfile.txt


wordcount-run_code () {
      clk wordcount testfile.txt
}

wordcount-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
5
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run wordcount-run'

{ wordcount-run_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/wordcount-run"
else
    wordcount-run_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying wordcount-run"
        exit 1
    }
fi



wordcount-completion_code () {
      clk completion try --last wordcount ./te
}

wordcount-completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./testfile.txt
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run wordcount-completion'

{ wordcount-completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/wordcount-completion"
else
    wordcount-completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying wordcount-completion"
        exit 1
    }
fi



completion-show_code () {
      clk completion show | head -6
}

completion-show_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
_clk_completion() {
    local IFS=$'\n'
    local response

    response=$(env COMP_WORDS="${COMP_WORDS[*]}" COMP_CWORD=$COMP_CWORD _CLK_COMPLETE=bash_complete $1)

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion-show'

{ completion-show_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/completion-show"
else
    completion-show_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion-show"
        exit 1
    }
fi



wordcount-completion-upper_code () {
      clk completion try --last wordcount ./TE
}

wordcount-completion-upper_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run wordcount-completion-upper'

{ wordcount-completion-upper_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/wordcount-completion-upper"
else
    wordcount-completion-upper_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying wordcount-completion-upper"
        exit 1
    }
fi



wordcount-completion-insensitive_code () {
      clk completion --case-insensitive try --last wordcount ./TE
}

wordcount-completion-insensitive_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./testfile.txt
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run wordcount-completion-insensitive'

{ wordcount-completion-insensitive_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/wordcount-completion-insensitive"
else
    wordcount-completion-insensitive_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying wordcount-completion-insensitive"
        exit 1
    }
fi


clk command create bash showpackage
cat <<"EOH" > "$(clk command which showpackage)"
#!/usr/bin/env bash
  set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Show the package location
--
A:package:file:Package to install
EOF
}

clk_help_handler "$@"

echo "$(clk_value package)"

EOH


urlarg-run_code () {
      clk showpackage https://example.com/path/to/package.apk
}

urlarg-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
https://example.com/path/to/package.apk
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run urlarg-run'

{ urlarg-run_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/urlarg-run"
else
    urlarg-run_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying urlarg-run"
        exit 1
    }
fi


clk command create bash greet
cat <<"EOH" > "$(clk command which greet)"
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Greet someone
--
O:--times:int:How many times to greet:1
F:--loud/--quiet:Greet in capital case:True
EOF
}

clk_help_handler "$@"

msg=hello
if clk_true loud
then
    msg=HELLO
fi
for i in $(seq 1 "${CLK___TIMES}")
do
    echo "${msg}"
done
EOH


old-greet-run_code () {
      clk greet
}

old-greet-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[35mdeprecated: [0mIn greet, O:--times:int:How many times to greet:1 gives its default after a colon. Give it in the json that ends the line instead, like O:name:type:help:{"default": "value"}
[35mdeprecated: [0mIn greet, F:--loud/--quiet:Greet in capital case:True gives its default after a colon. Give it in the json that ends the line instead, like F:name:help:{"default": true}
HELLO
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run old-greet-run'

{ old-greet-run_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/old-greet-run"
else
    old-greet-run_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying old-greet-run"
        exit 1
    }
fi


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


greet-run_code () {
      clk greet --times 2
}

greet-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
HELLO
HELLO
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run greet-run'

{ greet-run_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/greet-run"
else
    greet-run_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying greet-run"
        exit 1
    }
fi
# giving the defaults in json:7 ends here
