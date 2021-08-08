#!/usr/bin/env python
# -*- coding:utf-8 -*-
from __future__ import print_function, absolute_import

import click


def click_get_current_context_safe():
    try:
        return click.get_current_context()
    except RuntimeError:
        return None
