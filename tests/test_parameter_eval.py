#!/usr/bin/env python3
def test_use_value_as_parameter(lib):
    # when I create a value
    lib.cmd("value set a b")
    # and I use that value as a parameter of another command
    lib.cmd("parameter set echo noeval:value:a")
    # then, when running the command, the parameters uses the value
    assert lib.cmd("echo") == "b"
