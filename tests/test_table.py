#!/usr/bin/env python3

import json


def test_table(lib, pythondir):
    # given a group of commands that allows playing with http
    (pythondir / "table.py").write_text("""#!/usr/bin/env python3
# -*- coding:utf-8 -*-


import click
from clk.config import config
from clk.decorators import (argument, command, flag, option, table_fields,
                            table_format, use_settings)
from clk.lib import TablePrinter, call
from clk.log import get_logger
from clk.types import DynamicChoice

LOGGER = get_logger(__name__)


@command()
@table_format(default='key_value')
@table_fields(choices=['col1', 'col2', 'col3'])
def table(fields, format):
    "Write something in a table"
    with TablePrinter(fields, format) as tp:
        tp.echo(1, 2, 3)
        tp.echo("a", "b", "c")
""")
    assert (
        lib.cmd("table")
        == """
1 2 3
a b c
""".strip()
    )
    assert (
        lib.cmd("table --format orgtbl")
        == """
| col1   | col2   | col3   |
|--------+--------+--------|
| 1      | 2      | 3      |
| a      | b      | c      |
""".strip()
    )
    assert json.loads(lib.cmd("table --format json --field col2")) == [
        {"col2": 2},
        {"col2": "b"},
    ]
