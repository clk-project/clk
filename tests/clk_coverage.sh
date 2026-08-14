#!/usr/bin/env bash

set -u
set -e

base_dir="$(readlink -f "$(dirname "$0")")"
if test "${base_dir}" = "$(pwd)"
then
    echo "Won't mess up with the coverage'"
    exit 1
fi

base_coverage="${base_dir}/.coverage.${CLK_COVERAGE_TEST_ID}"
cur_coverage="$(pwd)/.coverage"

args=()

if test -e "${base_coverage}"
then
    args+=(--append)
fi

set +e
context_args=""
if test -n "${CLK_COVERAGE_CONTEXT-}"
then
    context_args="--context=${CLK_COVERAGE_CONTEXT}"
fi
"${PYTHON}" -u -m coverage run --source clk ${context_args} -m clk "$@"
res=$?
set -e

pushd "${base_dir}" > /dev/null
{
    COVERAGE_FILE="${base_coverage}" coverage combine "${args[@]}" "${cur_coverage}">/dev/null 2>/dev/null
}
popd > /dev/null

exit $res
