#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import click

from clk.decorators import argument, command, flag
from clk.lib import createfile, makedirs, rm


@command()
@argument('name', help='The name of the new project, also the name of the output directory')
@flag('--force/--no-force', help='Remove the output directory if it exist before proceeding')
def fork(force, name):
    """Create a brand new project, based on clk that can be used by itself."""
    output = Path(name)
    if output.exists():
        if force:
            rm(output)
        else:
            raise click.UsageError(f'{output} already exist')
    makedirs(output)
    createfile(
        output / 'setup.py', f"""#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from setuptools import setup, find_packages

setup(
    name='{name}',
    version="0.0.0",
    packages=find_packages(),
    zip_safe=False,
    install_requires=[
        "clk",
    ],
    entry_points={{
        'console_scripts':
        [
            '{name}={name}.main:main',
        ]
    }},
)
""")
    package = (output / name)
    makedirs(package)
    createfile(
        package / 'main.py', f"""#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from clk.setup import basic_entry_point, main
from clk.decorators import command, argument, flag, option


@basic_entry_point(
__name__,
extra_command_packages=["{name}.commands"],
exclude_core_commands=["git-sync"],
)
def {name}(**kwargs):
    pass

if __name__ == "__main__":
    main()
""")
    createfile(package / '__init__.py', """#!/usr/bin/env python3""")
    commands = (package / 'commands')
    makedirs(commands)
    (commands / 'somecommand.py', """#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import click
from clk.decorators import command, argument, flag, option
from clk.log import get_logger


LOGGER = get_logger(__name__)


@command()
@argument("some-argument", help="some argument")
@flag("--some-flag/--no-some-flag", help="some flag")
@option("--some-option", help="some option")
def somecommand(some_argument, some_flag, some_option):
    "Some command"
    LOGGER.info(some_argument)
    LOGGER.info(some_flag)
    LOGGER.info(some_option)
""")
    print(f'Now, install {name} with `python3 -m pip install {name}`,'
          f' enable its completion with `{name} completion install`'
          f" and don't forget to have fun")
