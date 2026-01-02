#!/usr/bin/env python
from abc import ABC, abstractmethod


class CommandResolver(ABC):
    @abstractmethod
    def _list_command_paths(self, parent): ...

    @abstractmethod
    def _get_command(self, path, parent): ...

    @abstractmethod
    def add_edition_hint(self, ctx, command, formatter): ...
