#!/usr/bin/env python

import click
from click.core import ParameterSource


def click_get_current_context_safe():
    try:
        return click.get_current_context()
    except RuntimeError:
        return None


def was_explicitly_provided(ctx, param_name):
    """Check if a parameter was explicitly provided (not from defaults).

    This abstracts away the Click internal ParameterSource enum, reducing
    coupling to Click internals throughout the codebase.
    """
    return ctx.get_parameter_source(param_name) != ParameterSource.DEFAULT
