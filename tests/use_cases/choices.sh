#!/usr/bin/env bash
# [[file:../../doc/use_cases/choices.org::run][run]]
set -eu
. ./sandboxing.sh
clk command create python android --force --group --body "$(cat<<EOF
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
type=click.Choice(devices),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
EOF
)"
clk command create bash android.battery.status --force --description "Print the battery level of the device" --body 'echo "Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for ${ANDROID_DEVICE} available at ${ANDROID_SERIAL}"'

batterie-status-test_code () {
      clk android -d cink-peax battery status
}

batterie-status-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for cink-peax available at 192.168.1.10:5555
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run batterie-status-test'

{ batterie-status-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/batterie-status-test"
else
    batterie-status-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying batterie-status-test"
        exit 1
    }
fi


try-bad-name-choice_code () {
      clk android -d cinkpeax battery status
}

try-bad-name-choice_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk android [OPTIONS] COMMAND [ARGS]...
error: Invalid value for '--device' / '-d': 'cinkpeax' is not one of 'cink-peax', 'i9300', 'klipad'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-bad-name-choice'

{ try-bad-name-choice_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-bad-name-choice"
else
    try-bad-name-choice_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-bad-name-choice"
        exit 1
    }
fi

clk command create python android --force --group --body "$(cat<<EOF
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
from clk.types import Suggestion
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
    type=Suggestion(devices),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
EOF
)"

test-with-suggestion_code () {
      clk android -d 192.168.1.14:5555 battery status
}

test-with-suggestion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for 192.168.1.14:5555 available at 192.168.1.14:5555
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-with-suggestion'

{ test-with-suggestion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/test-with-suggestion"
else
    test-with-suggestion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-with-suggestion"
        exit 1
    }
fi


try-completion_code () {
      clk completion try --remove-bash-formatting --last android -d kli
}

try-completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
klipad
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-completion'

{ try-completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-completion"
else
    try-completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-completion"
        exit 1
    }
fi

clk command create python android --force --group --body "$(cat<<EOF
import os
from pathlib import Path

import click
from clk.config import config
from clk.decorators import group, option
from clk.lib import call, check_output
from clk.log import get_logger
from clk.types import DocumentedChoice
docs = {
    'cink-peax': 'My pomodoro',
    'i9300': 'My vacuum automator',
    'klipad': 'The photo gallery',
}
LOGGER = get_logger(__name__)

devices = {
    'cink-peax': '192.168.1.10:5555',
    'i9300': '192.168.1.11:5555',
    'klipad': '192.168.1.12:5555',
}

@group()
@option(
    '--device',
    '-d',
    help='What device to connect to',
    type=DocumentedChoice(docs),
)
def android(device):
    'Play with android'
    config.override_env['ANDROID_DEVICE'] = device
    device = devices.get(device, device)
    config.override_env['ANDROID_SERIAL'] = device
    config.init()
EOF
)"

test-documented-choices_code () {
      clk android -d cinkpeax battery status
}

test-documented-choices_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk android [OPTIONS] COMMAND [ARGS]...
error: Invalid value for '--device' / '-d': 'cinkpeax'.
error: Choose from:
error:   cink-peax    My pomodoro
error:   i9300        My vacuum automator
error:   klipad       The photo gallery
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-documented-choices'

{ test-documented-choices_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/test-documented-choices"
else
    test-documented-choices_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-documented-choices"
        exit 1
    }
fi


test-documented-choices2_code () {
      clk android -d cink-peax battery status
}

test-documented-choices2_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for cink-peax available at 192.168.1.10:5555
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-documented-choices2'

{ test-documented-choices2_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/test-documented-choices2"
else
    test-documented-choices2_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-documented-choices2"
        exit 1
    }
fi


try-completion2_code () {
      clk completion try --remove-bash-formatting --last android -d i
}

try-completion2_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
i9300
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-completion2'

{ try-completion2_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-completion2"
else
    try-completion2_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-completion2"
        exit 1
    }
fi


try-style_code () {
      clk completion try --last echo --style "" | head -4
}

try-style_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
black
red
green
yellow
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-style'

{ try-style_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-style"
else
    try-style_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-style"
        exit 1
    }
fi


try-foreground_code () {
      clk completion try --last echo --style "fg-" | head -3
}

try-foreground_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
fg-black
fg-red
fg-green
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-foreground'

{ try-foreground_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-foreground"
else
    try-foreground_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-foreground"
        exit 1
    }
fi


try-unknown-colour_code () {
      clk echo --style pink hello
}

try-unknown-colour_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk echo [OPTIONS] [MESSAGE]...
error: Invalid value for '-s' / '--style': invalid style: pink. (Unknown color 'pink')
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-unknown-colour'

{ try-unknown-colour_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-unknown-colour"
else
    try-unknown-colour_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-unknown-colour"
        exit 1
    }
fi


try-unknown-part_code () {
      clk echo --style wiggle-True hello
}

try-unknown-part_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk echo [OPTIONS] [MESSAGE]...
error: Invalid value for '-s' / '--style': invalid style: wiggle. (choose from fg, bg, dim, bold, underline, blink, reverse, reset)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-unknown-part'

{ try-unknown-part_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-unknown-part"
else
    try-unknown-part_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-unknown-part"
        exit 1
    }
fi

clk echo --style bold-True,fg-green hello

echo-with-style_code () {
      clk --force-color echo --style bold-True,fg-green hello
}

echo-with-style_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[32m[1mhello[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run echo-with-style'

{ echo-with-style_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/echo-with-style"
else
    echo-with-style_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying echo-with-style"
        exit 1
    }
fi
# run ends here
