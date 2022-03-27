#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import pytest

from clk import lib


def test_ln():
    Path('a').write_text('a')
    lib.ln('a', Path('b'))
    assert Path('b').read_text() == 'a'
    Path('a').write_text('b')
    assert Path('b').read_text() == 'b'
    with pytest.raises(FileExistsError):
        lib.ln(Path('a'), 'b')
    lib.dry_run = True
    lib.ln(Path('a'), 'b')
    lib.dry_run = None
    lib.rm('a')
    with pytest.raises(FileNotFoundError):
        Path('b').read_text()


def test_link():
    Path('a').write_text('a')
    lib.link('a', Path('b'))
    assert Path('b').read_text() == 'a'
    Path('a').write_text('b')
    assert Path('b').read_text() == 'b'
    with pytest.raises(FileExistsError):
        lib.link(Path('a'), 'b')
    lib.dry_run = True
    lib.link(Path('a'), 'b')
    lib.dry_run = None
    lib.rm('a')
    assert Path('b').read_text() == 'b'


def test_natural_time():
    assert lib.natural_time(5) == '5 seconds ago'


def test_which():
    assert lib.which('ls') in ('/usr/bin/ls', '/bin/ls')
