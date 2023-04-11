#!/bin/bash -eu
# [[file:rolling_your_own.org::+BEGIN_SRC bash :tangle rolling_your_own.sh :exports none :noweb yes :shebang "#!/bin/bash -eu"][No heading:11]]
. ./sandboxing.sh

clk fork mytool

python3 -m venv venv
. ./venv/bin/activate

python3 -m pip install ./mytool

python3 -m pip install "${CURRENT_CLK}"

mkdir -p "${TMP}/mytool-root"
cat <<EOF > "${TMP}/mytool-root/mytool.json"
{
    "parameters": {
        "command.create.python": [
            "--no-open"
        ],
        "command.create.bash": [
            "--no-open"
        ]
    }
}
EOF
eval "$(direnv hook bash)"
export MYTOOLCONFIGDIR=${TMP}/mytool-root
echo "export MYTOOLCONFIGDIR=${TMP}/mytool-root" >> "${TMP}/.envrc" && direnv allow

mytool command create bash hello-world --description "Just say hello" --body 'echo "Hello world"'


call_code () {
      mytool hello-world
}

call_expected () {
      cat<<EOEXPECTED
Hello world
EOEXPECTED
}

diff -u <(call_code) <(call_expected)


mytool --help
# No heading:11 ends here
