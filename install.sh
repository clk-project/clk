#!/usr/bin/env bash

set -e

_check_pip () {
    local good_version="$(python3 -c '
import re
import pip

version_number=int(re.match("^([0-9]+)\.", pip.__version__).group(1))
print(version_number >= 19)
')"
    [ "${good_version}" == "True" ]
}

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
    elif which python3.9 > /dev/null
    then
        PYTHON=python3.9
    elif which python3.8 > /dev/null
    then
        PYTHON=python3.8
    else
        printf "${yellow}warning:${reset} Could not find a suitable python version (at least 3.8).\n"
        printf "${yellow}warning:${reset} Make sure one is installed and available.\n"
        printf "${yellow}warning:${reset} Hint: on debian-like systems -> sudo apt install python3.9.\n"
        exit 1
    fi
    echo "Using this command to run python: ${PYTHON}"
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
    }
fi


if [ "$(uname)" == "Darwin" ]; then
    if ! which pip3 > /dev/null; then
        if ! which brew > /dev/null; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        brew install python3
    fi
    PIP=pip3
    USER_OPT=
    INSTALL_PATH=/usr/local/bin
else
    if ! which wget > /dev/null && ! which curl > /dev/null; then
        if which sudo apt-get > /dev/null; then
            sudo apt-get install -y curl python3-distutils
        elif which sudo yum > /dev/null; then
            sudo yum -y install curl
        fi
    fi

    INSTALL_PATH=$HOME/.local/bin

    mkdir -p "${INSTALL_PATH}"
    touch "${INSTALL_PATH}/somedummyscripttotest"
    chmod +x "${INSTALL_PATH}/somedummyscripttotest"
    ASK_NEW_BASH=""
    if ! which somedummyscripttotest > /dev/null
    then
        export PATH="${INSTALL_PATH}:${PATH}"
        echo "export PATH='${INSTALL_PATH}:${PATH}'" >> "${HOME}/.bashrc"
        ASK_NEW_BASH="1"
    fi
    rm "${INSTALL_PATH}/somedummyscripttotest"

    _find_suitable_python_version

    if ! _check_pip
    then
        # we need to force the reinstall in order to make sure the latest version of
        # pip is there
        GET_PIP_TMP_DIR="${TMPDIR:-/tmp}/get-pip.py"
        if which curl > /dev/null; then
            curl -sSL https://bootstrap.pypa.io/get-pip.py -o "${GET_PIP_TMP_DIR}"
            "${PYTHON}" ${TMPDIR:-/tmp}/get-pip.py --force-reinstall --user --quiet & spin "installing pip"
        elif which wget > /dev/null; then
            wget -nv https://bootstrap.pypa.io/get-pip.py -O "${GET_PIP_TMP_DIR}"
            "${PYTHON}" ${TMPDIR:-/tmp}/get-pip.py --force-reinstall --user --quiet & spin "installing pip"
        else
            echo "Error: can't find or install pip"
            exit 1
        fi
        trap "rm '${GET_PIP_TMP_DIR}'" 0
    fi
    if ! _check_pip
    then
        echo "Error: we could not install a suitable pip version..."
        exit 1
    fi
    PIP="${PYTHON} -m pip"
    USER_OPT=--user
fi

if which clk > /dev/null 2>&1
then
    verb="updating"
else
    verb="installing"
fi

CLK="${CLK:-clk}"
${PIP} install ${USER_OPT} --quiet --upgrade "${CLK}" & spin "${verb} ${CLK}"

echo -n "installing clk completion... "
for s in bash zsh fish; do
    $INSTALL_PATH/clk -L warning completion install $s
done
echo "done"

if [ "${ASK_NEW_BASH}" == "1" ]
then
    $INSTALL_PATH/clk log --level warning "You have to restart bash to see clk working"
fi

echo -e "${green}clk successfully installed! Enjoy!${reset}"
for extension in ${CLK_EXTENSIONS}
do
    echo "installing clk extension ${extension}... "
    "${INSTALL_PATH}/clk" extension install "${extension}"
done
