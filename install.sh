#!/usr/bin/env bash

set -e


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
            sudo apt-get install -y curl
        elif which sudo yum > /dev/null; then
            sudo yum -y install curl
        fi
    fi
    # we need to force the reinstall in order to make sure the latest version of
    # pip is there
    GET_PIP_TMP_DIR="${TMPDIR:-/tmp}/get-pip.py"
    if which python3 curl > /dev/null; then
        curl -sSL https://bootstrap.pypa.io/get-pip.py -o "${GET_PIP_TMP_DIR}"
        python3 ${TMPDIR:-/tmp}/get-pip.py --force-reinstall --user --quiet & spin "installing pip"
    elif which python wget > /dev/null; then
        wget -nv https://bootstrap.pypa.io/get-pip.py -O "${GET_PIP_TMP_DIR}"
        python3 ${TMPDIR:-/tmp}/get-pip.py --force-reinstall --user --quiet & spin "installing pip"
    else
        echo "Error: can't find or install pip"
        exit 1
    fi
    trap "rm '${GET_PIP_TMP_DIR}'" 0
    PIP=$HOME/.local/bin/pip3
    USER_OPT=--user
    INSTALL_PATH=$HOME/.local/bin
fi

${PIP} install ${USER_OPT} --quiet --upgrade click-project & spin "installing clk"

echo -n "installing clk completion... "
for s in bash zsh fish; do
    $INSTALL_PATH/clk -L warning completion install $s
done
echo "done"

if ! which clk > /dev/null; then
    if ! [ -e "${HOME}/bin/clk" ]
    then
        mkdir -p "${HOME}/bin"
        ln -s "${INSTALL_PATH}/clk" "${HOME}/bin/"
    fi
    if ! which clk > /dev/null; then
        echo -e "${yellow}You will need to logout and login again!${reset}"
    fi
fi
echo -e "${green}clk successfully installed! Enjoy!${reset}"
for recipe in ${CLK_RECIPES}
do
    echo "installing clk recipe ${recipe}... "
    "${INSTALL_PATH}/clk" recipe install "${recipe}"
done
