#!/usr/bin/env python
"""Helpers to abstract Click internal APIs.

This module centralizes all access to Click's private and unstable APIs
(such as _parameter_source, ParameterSource, protected_args, etc.).

By isolating this coupling here, the rest of the codebase remains insulated
from Click internals. When Click changes its internal APIs (e.g., the
deprecation of protected_args in Click 8.2), only this module needs updating.
"""

from click.core import ParameterSource


def get_click_params(f):
    """Return the click parameters of a command."""
    return f.__click_params__


def was_explicitly_provided(ctx, param_name):
    """Check if a parameter was explicitly provided (not from defaults).

    This abstracts away the Click internal ParameterSource enum, reducing
    coupling to Click internals throughout the codebase.
    """
    return ctx.get_parameter_source(param_name) != ParameterSource.DEFAULT


def clear_parameter_source(ctx, param_name):
    """Clear the parameter source for a given parameter name.

    This abstracts away the Click internal _parameter_source dict,
    reducing coupling to Click internals.
    """
    if param_name in ctx._parameter_source:
        del ctx._parameter_source[param_name]


def get_unparsed_args(ctx):
    """Get unparsed arguments that will be passed to subcommands.

    Abstracts ctx.protected_args which is deprecated in Click 8.2.
    In Click 9.0, this will need to use ctx.args instead.
    """
    return ctx.protected_args + ctx.args


def has_unparsed_args(ctx):
    """Check if there are unparsed arguments for subcommands.

    Abstracts ctx.protected_args which is deprecated in Click 8.2.
    """
    return bool(ctx.protected_args or ctx.args)


def get_protected_args(ctx):
    """Get the protected args from a context.

    Abstracts ctx.protected_args access (deprecated in Click 8.2).
    """
    return ctx.protected_args


def set_protected_args(ctx, args):
    """Set the protected args on a context.

    Abstracts ctx._protected_args assignment since protected_args is read-only.
    """
    ctx._protected_args = args
