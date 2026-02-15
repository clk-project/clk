#!/bin/bash

set -u
set -e

base_dir="$(readlink -f "$(dirname "$0")")"
if test "${base_dir}" = "$(pwd)"
then
    echo "Won't mess up with the coverage'"
    exit 1
fi

# Use per-test coverage file if CLK_COVERAGE_TEST_ID is set
if test -n "${CLK_COVERAGE_TEST_ID-}"
then
    base_coverage="${base_dir}/.coverage.${CLK_COVERAGE_TEST_ID}"
else
    base_coverage="${base_dir}/.coverage"
fi
cur_coverage="$(pwd)/.coverage"

args=()

if test -e "${base_coverage}"
then
    args+=(--append)
fi

set +e
if test -z "${CLK_BIN-}"
then
    CLK_BIN="$(readlink -f "$(which clk)")"
fi
CLK_BIN_PATH="${CLK_BIN%/*}"
PYTHON="${CLK_BIN_PATH}/python"
# if this path exists, clk is most likely installed in a venv, using that
# version of python to get to the coverage
if ! test -e "${PYTHON}"
then
    PYTHON=python3
fi
"${PYTHON}" -u -m coverage run --source clk -m clk "$@"
res=$?
set -e

pushd "${base_dir}" > /dev/null
{
    COVERAGE_FILE="${base_coverage}" coverage combine "${args[@]}" "${cur_coverage}">/dev/null 2>/dev/null
}
popd > /dev/null

exit $res
