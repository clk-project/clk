#!/usr/bin/env python3


def test_main_help(lib):
    some_part_of_the_help_message = (
        "We truly believe that command line usage should be fast, intuitive"
    )
    assert some_part_of_the_help_message in lib.cmd("--help")
    assert some_part_of_the_help_message in lib.cmd("help")


def test_command_help(lib):
    some_part_of_the_help_message = "-n, --no-newline / --newline"
    assert some_part_of_the_help_message in lib.cmd("echo --help")
    assert some_part_of_the_help_message in lib.cmd("help echo")


def test_group_help(lib):
    some_part_of_the_help_message = (
        "append      Add a parameter after the parameters of a command"
    )
    assert some_part_of_the_help_message in lib.cmd("parameter --help")
    assert some_part_of_the_help_message in lib.cmd("help parameter")
