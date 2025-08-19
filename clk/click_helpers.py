#!/usr/bin/env python

import click


def click_get_current_context_safe():
    try:
        return click.get_current_context()
    except RuntimeError:
        return None
