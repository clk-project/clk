#!/bin/bash

set -u
set -e

base_dir="$(readlink -f "$(dirname "$0")")"
if test "${base_dir}" = "$(pwd)"
then
    echo "Won't mess up with the coverage'"
    exit 1
fi
base_coverage="${base_dir}/.coverage"
cur_coverage="$(pwd)/.coverage"

args=()

if test -e "${base_coverage}"
then
    args+=(--append)
fi

set +e
python3 -u -m coverage run --source clk -m clk "$@"
res=$?
set -e

pushd "${base_dir}" > /dev/null
{
    coverage combine "${args[@]}" "${cur_coverage}">/dev/null 2>/dev/null
}
popd > /dev/null

exit $res
