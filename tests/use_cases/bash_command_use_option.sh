#!/bin/bash -eu
# [[id:100aa89b-f320-46ee-9d5d-2193ef48d4eb::+BEGIN_SRC bash :exports none :tangle ../../tests/use_cases/bash_command_use_option.sh :noweb yes :shebang "#!/bin/bash -eu"][No heading:8]]
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
# No heading:8 ends here
