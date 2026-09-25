#!/usr/bin/env bash
# [[file:../../doc/use_cases/setting_default_values.org::#git-comparison][a familiar pattern: git config:3]]
set -eu
. ./sandboxing.sh


set-parameters-verbose_code () {
      clk parameter set alias.show --no-color
      clk parameter set parameter.show --no-color
      clk parameter set value.show --no-color
      clk parameter set extension.show --no-color
}

set-parameters-verbose_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m parameters for alias.show: --no-color
New [36mglobal[0m parameters for parameter.show: --no-color
New [36mglobal[0m parameters for value.show: --no-color
New [36mglobal[0m parameters for extension.show: --no-color
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-parameters-verbose'

{ set-parameters-verbose_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/set-parameters-verbose"
else
    set-parameters-verbose_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-parameters-verbose"
        exit 1
    }
fi


clk parameter unset alias.show
clk parameter unset parameter.show
clk parameter unset value.show
clk parameter unset extension.show

clk value set config.show.color false

clk alias set hello echo Hello
clk parameter set hello --some-option


show-help-color_code () {
      clk alias show --help 2>&1 | grep -- "--color"
}

show-help-color_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  --color / --no-color            Show profiles in color  [default: no-color]
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-help-color'

{ show-help-color_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-help-color"
else
    show-help-color_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-help-color"
        exit 1
    }
fi



set-other-values_code () {
      clk value set config.show.legend false
      clk value show
}

set-other-values_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
config.show.color false
config.show.legend false
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-other-values'

{ set-other-values_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/set-other-values"
else
    set-other-values_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-other-values"
        exit 1
    }
fi



set-default-option_code () {
      clk value set default.alias.show.format plain
      clk alias show --help 2>&1 | grep -A1 -- "--format" | tail -1 | sed -r 's|^.+(default: [a-zA-Z-]+).+$|\1|'
}

set-default-option_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
default: plain
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-default-option'

{ set-default-option_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/set-default-option"
else
    set-default-option_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-default-option"
        exit 1
    }
fi


clk command create python show-items --no-open --force
cat <<'EOF' > "$(clk command which show-items)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import click

from clk.decorators import command, option
from clk.config import config


@command()
@option(
    "--color/--no-color",
    default=config.get_value("config.show.color", True),
    help="Show output in color",
)
def show_items(color):
    "Display some items"
    items = ["apple", "banana", "cherry"]
    for item in items:
        if color:
            click.secho(item, fg="green")
        else:
            click.echo(item)
EOF


show-custom-help_code () {
      clk show-items --help 2>&1 | grep -- "--color"
}

show-custom-help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  --color / --no-color  Show output in color  [default: no-color]
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-custom-help'

{ show-custom-help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-custom-help"
else
    show-custom-help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-custom-help"
        exit 1
    }
fi



change-value-true_code () {
      clk value set config.show.color true
      clk show-items --help 2>&1 | grep -- "--color"
      clk alias show --help 2>&1 | grep -- "--color"
}

change-value-true_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  --color / --no-color  Show output in color  [default: color]
  --color / --no-color            Show profiles in color  [default: color]
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run change-value-true'

{ change-value-true_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/change-value-true"
else
    change-value-true_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying change-value-true"
        exit 1
    }
fi


clk value set config.show.color false

clk value set myapp.color true


unset-value_code () {
      clk value unset myapp.color
      clk value show 2>&1 | grep -q myapp.color || echo "myapp.color is gone"
}

unset-value_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
myapp.color is gone
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-value'

{ unset-value_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unset-value"
else
    unset-value_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unset-value"
        exit 1
    }
fi
# a familiar pattern: git config:3 ends here
