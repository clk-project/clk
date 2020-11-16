#!/bin/bash -eu

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
