#!/bin/bash -eu

clk_import ( ) {
    local dep="$1"
    source "$(dirname "${0}")/lib/${dep}"
}

clk_list_to_choice () {
    echo "[$(sed -r 's-(.+)- "\1"-'| paste -s - -d,)]"
}

clk_abort () {
	local message="${1:-Aborting}"
	local code="${2:-1}"
	clk log -l error "${message}"
	exit "${code}"
}

clk_help_handler () {
	if [ $# -gt 0 ] && [ "$1" == "--help" ]
	then
		clk_usage
		exit 0
	fi
}

_log () {
	clk log "$@"
}

_info () {
	_log -l info "$@"
}

clk_in_project () {
	pushd "${CLK__PROJECT}" > /dev/null
}

clk_end_in_project () {
	popd > /dev/null
}

clk_wait_for_line () {
	local line="$1"
	line="$(echo "${line}"|sed 's/\//\\\//g')"
	exec sed -n "/${line}/q"
}

clk_wait_for_line_tee () {
	local line="$1"
	line="$(echo "${line}"|sed 's/\//\\\//g')"
	exec sed "/${line}/q"
}

clk_pid_exists () {
	local pid="$1"
	ps -p "${1}" > /dev/null 2>&1
}
