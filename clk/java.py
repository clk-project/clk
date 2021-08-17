#!/usr/bin/env python
# -*- coding: utf-8 -*-

from clk.decorators import option


def java_debug_options(func):
    opts = [
        option(
            '--debugger/--no-debugger',
            help='Trigger debugging of the java program',
        ),
        option(
            '--debugger-agent-port',
            help='Specify port for java agent debugger',
            default=5005,
        ),
        option(
            '--debugger-suspend/--no-debugger-suspend',
            help='Like --debugger, but the debugged program will wait for you',
            default=False,
        ),
    ]
    for opt in reversed(opts):
        func = opt(func)
    return func


def add_java_debug_args(debugger, debugger_agent_port, debugger_suspend):
    if debugger or debugger_suspend:
        debugger_suspend_string = 'y' if debugger_suspend else 'n'
        return [
            '-agentlib:jdwp=transport=dt_socket,server=y,suspend=' + debugger_suspend_string + ',address=*:' +
            str(debugger_agent_port)
        ]
    return []
