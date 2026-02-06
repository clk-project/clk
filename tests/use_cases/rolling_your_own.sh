#!/bin/bash -eu
# [[file:../../doc/use_cases/tests/use_cases/rolling_your_own.sh :exports none :noweb yes :shebang "#!/bin/bash -eu"][No heading:10]]
. ./sandboxing.sh

clk fork mytool

CURRENT_CLK="$(clk python -c 'from pathlib import Path; import clk ; print(Path(clk.__path__[0]).parent)')"

python3 -m venv venv
./venv/bin/pip install ./mytool
export PATH="$(pwd)/venv/bin/:${PATH}"

# this reproduces the logic in the INSTALLER function in the root Earthfile. It
# might be good to refactor this in the future.
from=${from-}
if test "$from" = "pypi"
then
    ./venv/bin/pip install clk${pypi_version}
elif test "$from" = "build"
then
    ./venv/bin/pip install /dist/*
else
    # fall back in assuming that I run this from my machine, where clk is
    # installed in editable mode
    ./venv/bin/pip install --force-reinstall "${CURRENT_CLK}"
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

echo 'Run call'

{ call_code || true ; } > "${TMP}/code.txt" 2>&1
call_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call"
exit 1
}


mytool --help
# No heading:10 ends here
