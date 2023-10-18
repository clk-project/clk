#!/bin/bash -eu
# [[file:rolling_your_own.org::+BEGIN_SRC bash :tangle rolling_your_own.sh :exports none :noweb yes :shebang "#!/bin/bash -eu"][No heading:10]]
. ./sandboxing.sh

clk fork mytool

CURRENT_CLK="$(clk python -c 'from pathlib import Path; import clk ; print(Path(clk.__path__[0]).parent)')"

python3 -m venv venv
./venv/bin/pip install ./mytool
export PATH="$(pwd)/venv/bin/:${PATH}"

if test -e /dist/clk*
then
    # installing the version of clk that was left here. It matches the one we are currently testing
   ./venv/bin/pip install /dist/*
else
   ./venv/bin/pip install "${CURRENT_CLK}"
fi

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
      cat<<"EOEXPECTED"
Hello world
EOEXPECTED
}

diff -uBw <(call_code 2>&1) <(call_expected) || {
echo "Something went wrong when trying call"
exit 1
}


mytool --help
# No heading:10 ends here
