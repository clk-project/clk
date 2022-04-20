#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import pytest


def test_get_none(lib):
    assert lib.cmd('password show something') == ''


def test_get_from_netrc_as_fallback(lib):
    lib.assert_intrusive()
    Path('~/.netrc').expanduser().write_text("""
machine something
login l
password p
""")
    assert lib.cmd('password show something') == 'l *****'
    assert lib.cmd('password show --password something') == 'l p'


def test_netrc_stuff(lib):
    lib.assert_intrusive()
    Path('~/.netrc').expanduser().write_text("""
machine something
login l
password p
""")
    from clk.netrc import Netrc
    netrc = Netrc()
    assert netrc.get_password('clk', 'something') == '["l", "p"]'
    with pytest.raises(NotImplementedError):
        netrc.set_password('clk', 'something', '["l", "p"]')
    with pytest.raises(NotImplementedError):
        netrc.delete_password('clk', 'something', '["l", "p"]')
