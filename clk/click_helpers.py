#!/usr/bin/env python
# -*- coding:utf-8 -*-
from __future__ import absolute_import, print_function

import click


def click_get_current_context_safe():
    try:
        return click.get_current_context()
    except RuntimeError:
        return None
