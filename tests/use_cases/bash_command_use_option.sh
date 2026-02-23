#!/bin/bash -eu
# [[file:../../doc/use_cases/bash_command_use_option.org::#dddf6c5e-3fce-4203-b75c-e918bcf3240f][completing against files:8]]
. ./sandboxing.sh

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

clk animal --help | grep -- 'KIND_OF_ANIMAL'
clk animal --help | grep -- '--sound-of-animal'
clk animal --help | grep -- '--shout'

test "$(clk animal duck --sound-of-animal couac)" = "duck does couac"
test "$(clk animal --sound-of-animal couac)" = "duck does couac"
test "$(clk animal whale --shout)" = "I DON'T KNOW WHAT SOUND WHALE MAKES"

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


wordcount-help_code () {
      clk wordcount --help | grep DOCUMENT
}

wordcount-help_expected () {
      cat<<"EOEXPECTED"
Usage: clk wordcount [OPTIONS] [DOCUMENT]
  DOCUMENT  The document to count words in  [default: None]
EOEXPECTED
}

echo 'Run wordcount-help'

{ wordcount-help_code || true ; } > "${TMP}/code.txt" 2>&1
wordcount-help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying wordcount-help"
exit 1
}


echo "one two three four five" > testfile.txt


wordcount-run_code () {
      clk wordcount testfile.txt
}

wordcount-run_expected () {
      cat<<"EOEXPECTED"
5
EOEXPECTED
}

echo 'Run wordcount-run'

{ wordcount-run_code || true ; } > "${TMP}/code.txt" 2>&1
wordcount-run_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying wordcount-run"
exit 1
}



wordcount-completion_code () {
      clk completion try --last wordcount ./te
}

wordcount-completion_expected () {
      cat<<"EOEXPECTED"
./testfile.txt
EOEXPECTED
}

echo 'Run wordcount-completion'

{ wordcount-completion_code || true ; } > "${TMP}/code.txt" 2>&1
wordcount-completion_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying wordcount-completion"
exit 1
}
# completing against files:8 ends here
