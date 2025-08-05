#!/bin/bash -eu
# [[id:3781d830-096f-4fb6-9e77-d18586507997::run][run]]
. ./sandboxing.sh
  mkdir -p "${CLKCONFIGDIR}/bin/lib"
  cat<<"EOF" > "${CLKCONFIGDIR}/bin/lib/termux"
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
EOF
clk command create bash termux.sms.send --no-open
cat <<"EOC" > "$(clk command which termux.sms.send)"
#!/bin/bash -eu

source "_clk.sh"

clk_import termux

clk_usage () {
    cat<<EOF
$0

Send a sms to some contacts of mine
--
A:name:$(termux-contact-names|clk_list_to_choice):This contact:-1
O:--message:str:What to say
EOF
}

clk_help_handler "$@"

EOC

command-completion-doit_code () {
      clk completion try --remove-bash-formatting --last termux sms send Mart
}

command-completion-doit_expected () {
      cat<<"EOEXPECTED"
Martha Thomas
EOEXPECTED
}

diff -uBw <(command-completion-doit_code 2>&1) <(command-completion-doit_expected) || {
echo "Something went wrong when trying command-completion-doit"
exit 1
}

cat<<"EOC" > "$(clk command which termux.sms.send)"
#!/bin/bash -eu

source "_clk.sh"

clk_import termux

clk_usage () {
    cat<<EOF
$0

Send a sms to some contacts of mine
--
A:name:$(termux-contact-names|clk_list_to_choice):This contact:-1
O:--message:str:What to say
EOF
}

clk_help_handler "$@"


clk_value name
EOC

try-with-clk-value_code () {
      clk termux sms send "Wendy Hodges" "Kyle Nguyen"
}

try-with-clk-value_expected () {
      cat<<"EOEXPECTED"
Wendy Hodges Kyle Nguyen
EOEXPECTED
}

diff -uBw <(try-with-clk-value_code 2>&1) <(try-with-clk-value_expected) || {
echo "Something went wrong when trying try-with-clk-value"
exit 1
}

cat<<"EOC" > "$(clk command which termux.sms.send)"
#!/bin/bash -eu

source "_clk.sh"

clk_import termux

clk_usage () {
    cat<<EOF
$0

Send a sms to some contacts of mine
--
A:name:$(termux-contact-names|clk_list_to_choice):This contact:-1
O:--message:str:What to say
EOF
}

clk_help_handler "$@"


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
EOC

try-with-json_code () {
      clk termux sms send "Wendy Hodges" "Kyle Nguyen"
}

try-with-json_expected () {
      cat<<"EOEXPECTED"
ssh myphone termux-sms-send -n "+987654321,+1122334455" "Hello there!"
EOEXPECTED
}

diff -uBw <(try-with-json_code 2>&1) <(try-with-json_expected) || {
echo "Something went wrong when trying try-with-json"
exit 1
}
# run ends here
