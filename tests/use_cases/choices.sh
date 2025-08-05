#!/bin/bash -eu
# [[id:d32467d3-931f-4df2-8277-3ed04a213eb2::run][run]]
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
      cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for cink-peax available at 192.168.1.10:5555
EOEXPECTED
}

diff -uBw <(batterie-status-test_code 2>&1) <(batterie-status-test_expected) || {
echo "Something went wrong when trying batterie-status-test"
exit 1
}


try-bad-name-choice_code () {
      clk android -d cinkpeax battery status
}

try-bad-name-choice_expected () {
      cat<<"EOEXPECTED"
Usage: clk android [OPTIONS] COMMAND [ARGS]...
error: Invalid value for '--device' / '-d': 'cinkpeax' is not one of 'cink-peax', 'i9300', 'klipad'.
EOEXPECTED
}

diff -uBw <(try-bad-name-choice_code 2>&1) <(try-bad-name-choice_expected) || {
echo "Something went wrong when trying try-bad-name-choice"
exit 1
}

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
      cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for 192.168.1.14:5555 available at 192.168.1.14:5555
EOEXPECTED
}

diff -uBw <(test-with-suggestion_code 2>&1) <(test-with-suggestion_expected) || {
echo "Something went wrong when trying test-with-suggestion"
exit 1
}


try-completion_code () {
      clk completion try --remove-bash-formatting --last android -d kli
}

try-completion_expected () {
      cat<<"EOEXPECTED"
klipad
EOEXPECTED
}

diff -uBw <(try-completion_code 2>&1) <(try-completion_expected) || {
echo "Something went wrong when trying try-completion"
exit 1
}

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
      cat<<"EOEXPECTED"
Usage: clk android [OPTIONS] COMMAND [ARGS]...
error: Invalid value for '--device' / '-d': 'cinkpeax'.
error: Choose from:
error:   cink-peax    My pomodoro
error:   i9300        My vacuum automator
error:   klipad       The photo gallery
EOEXPECTED
}

diff -uBw <(test-documented-choices_code 2>&1) <(test-documented-choices_expected) || {
echo "Something went wrong when trying test-documented-choices"
exit 1
}


test-documented-choices2_code () {
      clk android -d cink-peax battery status
}

test-documented-choices2_expected () {
      cat<<"EOEXPECTED"
Would call adb shell dumpsys battery|grep level|cut -f2 -d:|trim and would get the result for cink-peax available at 192.168.1.10:5555
EOEXPECTED
}

diff -uBw <(test-documented-choices2_code 2>&1) <(test-documented-choices2_expected) || {
echo "Something went wrong when trying test-documented-choices2"
exit 1
}


try-completion2_code () {
      clk completion try --remove-bash-formatting --last android -d i
}

try-completion2_expected () {
      cat<<"EOEXPECTED"
i9300
EOEXPECTED
}

diff -uBw <(try-completion2_code 2>&1) <(try-completion2_expected) || {
echo "Something went wrong when trying try-completion2"
exit 1
}
# run ends here
