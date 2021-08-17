#!/usr/bin/env python
# -*- coding: utf-8 -*-


class CommandResolver(object):
    def _list_command_paths(self, parent=None):
        raise NotImplementedError('The class method _list_command_paths must be implemented')

    def _get_command(self, path, parent):
        raise NotImplementedError('The class method get_method must be implemented')
