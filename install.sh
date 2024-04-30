#!/usr/bin/env bash

set -e

_check_python3 () {
    local good_version="$(python3 -c '
import re
import sys

version_number=int(re.match("^3\.([0-9]+)\.", sys.version).group(1))
print(version_number >= 8)
')"
    [ "${good_version}" == "True" ]
}

_find_suitable_python_version ( ) {
    if which python3 > /dev/null && _check_python3
    then
        PYTHON=python3
    else
        PYTHON=""
        for version in {20..8}
        do
            if which python3.$version > /dev/null
            then
                PYTHON=python3.$version
                break
            fi
        done
        if test -z "${PYTHON}"
        then
            printf "${yellow}warning:${reset} Could not find a suitable python version (at least 3.8).\n"
            printf "${yellow}warning:${reset} Make sure one is installed and available.\n"
            printf "${yellow}warning:${reset} Hint: on debian-like systems -> sudo apt install python3.9.\n"
            exit 1
        fi
    fi
    echo "Using this command to run python: ${PYTHON}"
}

_in_venv ( ) {
    # see https://stackoverflow.com/questions/1871549/determine-if-python-is-running-inside-virtualenv
    test "False" = "$("${PYTHON}" -c "import sys ; print(sys.prefix == sys.base_prefix)")"
}

_compute_install_path ( ) {
    if _in_venv
    then
        INSTALL_PATH="$(dirname "$(which "${PYTHON}")")"
    else
        INSTALL_PATH=$HOME/.local/bin
    fi
}

if [ -t 1 ]; then
    green="\e[32m"
    yellow="\e[33m"
    reset="\e[0m"
    function spin {
        msg=$1
        pid=$!
        spinchars='-\|/'
        i=0
        while kill -0 $pid 2> /dev/null; do
            i=$(( (i+1) %4 ))
            echo -e -n "\r${msg}... ${spinchars:$i:1}"
            sleep .3
        done
        echo -e "\r${msg}... done"
        wait $pid
    }
else
    green=""
    yellow=""
    reset=""
    function spin {
        msg=$1
        pid=$!
        echo -n "${msg}... "
        while kill -0 $pid 2> /dev/null; do
            sleep .1
        done
        echo "done"
        wait $pid
    }
fi

_find_suitable_python_version
_compute_install_path
CLK="${CLK:-clk}"

if which clk > /dev/null 2>&1
then
    verb="updating"
else
    verb="installing"
fi

if _in_venv
then
    CMD="pip install --quiet --upgrade"
else
    CMD="${PYTHON} -m pipx"
    if test "${verb}" = "installing"
    then
        CMD+=" install"
    else
        CMD+=" upgrade"
    fi
    # now, trying hard to make pipx available
    if [ "$(uname)" == "Darwin" ]; then
        if ! which pipx > /dev/null; then
            if ! which brew > /dev/null; then
                /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            fi
            brew install pipx
        fi
    else
        if ! which pipx > /dev/null && ! _in_venv
        then
            echo "I will try to install pipx myself. Therefore I will ask for sudo privileges"
            if which sudo > /dev/null
            then
                if which apt-get > /dev/null
                then
                    sudo apt-get install -y pipx
                elif which dnf > /dev/null
                then
                    sudo dnf --assumeyes pipx
                else
                    printf "${yellow}warning:${reset} Could not find apt, nor dnf, nor pipx. Please install pipx manually and retry.\n"
                    exit 1
                fi
            else
                printf "${yellow}warning:${reset} Could not find sudo, nor pipx. Please install pipx manually and retry.\n"
                exit 1
            fi
        fi
    fi
fi

${CMD} "${CLK}" & spin "${verb} ${CLK}"

echo -n "installing clk completion... "
for s in bash; do # zsh fish
    $INSTALL_PATH/clk -L warning completion install $s
done
echo "done"

if !which clk > /dev/null
then
    $INSTALL_PATH/clk log --level warning "You have to restart bash to see clk working"
fi

echo -e "${green}clk successfully installed! Enjoy!${reset}"
for extension in ${CLK_EXTENSIONS}
do
    echo "installing clk extension ${extension}... "
    "${INSTALL_PATH}/clk" extension install "${extension}"
done
