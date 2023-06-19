#!/bin/bash

clk_confirm () {
    local prompt="$1"
    local res
    read -p "${prompt} " res
    if echo "${res}" | grep -iq '^\(y\|yes\)$'
    then
        return 0
    else
        return 1
    fi
}

clk_name_to_env () {
    local name="$1"
    echo "CLK___$(echo "${name}"|sed -r 's/^-+//g'|sed 's/-/_/g'|tr '[:lower:]' '[:upper:]')"
}

clk_drop_duplicate () {
    cat -n | sort -uk2 | sort -n | cut -f2-
}

clk_value ( ) {
    local name="$1"
    local variable="$(clk_name_to_env "${name}")"
    local variable_call="\${${variable}}"
    echo "$(eval "echo \"${variable_call}\"")"
}

clk_extension ( ) {
    local value="$1"
    echo "${value}"|sed -r 's|^(.+)\.([^.]+)$|\2|'
}

clk_without_extension ( ) {
    local value="$1"
    echo "${value}"|sed -r 's|^(.+)\.([^.]+)$|\1|'
}

clk_given () {
    ! clk_null "$@"
}

clk_null ( ) {
    local name="$1"
    test "$(clk_value "${name}")" == ""
}

clk_true ( ) {
    local name="$1"
    test "$(clk_value "${name}")" = "True"
}

clk_false ( ) {
    ! clk_true "${@}"
}

clk_import ( ) {
    local dep="$1"
    source "$(dirname "${0}")/lib/${dep}"
}

clk_file ( ) {
    local name="$1"
    echo "$(dirname "${0}")/../files/${name}"
}

clk_cp_file () {
    local name="$1"
    local dst="$2"
    cp "$(clk_data "${name}")" "${dst}"
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

_clk_eval_env_by_name ( ) {
    local name="$1"
    echo "${!name}"
}

clk_debubp () {
    [ "$(_clk_eval_env_by_name ${CLK_APPNAME_UPPER}__LOG_LEVEL)" = "debug" ] \
        || [ "$(_clk_eval_env_by_name ${CLK_APPNAME_UPPER}__LOG_LEVEL)" = "develop" ] \
        || [ "$(_clk_eval_env_by_name ${CLK_APPNAME_UPPER}__DEBUG)" = "True" ] \
        || [ "$(_clk_eval_env_by_name ${CLK_APPNAME_UPPER}__DEVELOP)" = "True" ]
}

clk_help_handler () {
	if [ $# -gt 0 ] && [ "$1" == "--help" ]
	then
		clk_usage
		exit 0
	fi
    if clk_debubp
    then
        set -x
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

clk_wait_input ( ) {
    local msg="$1"
    clk log --notify "$msg"
    read -p "Press enter"
}

clk_popline ( ) {
    local file="$1"
    local variable="$2"
    if ! [ -s "${file}" ]
    then
        return 1
    fi
    local thehead="$(head -1 "${file}")"
    (
        # use a subshell to deal with a temp file
        TMPDIR="$(mktemp -d)"
        trap "rm -rf '${TMPDIR}'" 0
        tail +2 "${file}" > "${TMPDIR}/temp"
        mv "${TMPDIR}/temp" "${file}"
    )
    read "$2" < <(echo "${thehead}")
}

clk_out () {
    if clk_debubp
    then
        echo /dev/stdout
    else
        echo /dev/null
    fi
}

clk_err () {
    if clk_debubp
    then
        echo /dev/stderr
    else
        echo /dev/null
    fi
}

clk_format_choice () {
    echo -n '['
    echo -n "\"$1\""
    shift
    for arg in "$@"
    do
        echo -n ", \"${arg}\""
    done
    echo -n ']'
}
