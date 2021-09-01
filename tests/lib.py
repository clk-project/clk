#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call, check_output


def run(cmd, *args, **kwargs):
    return check_call(split(cmd), *args, **kwargs)


def out(cmd, *args, **kwargs):
    return check_output(split(cmd), *args, encoding='utf-8', **kwargs).strip()
