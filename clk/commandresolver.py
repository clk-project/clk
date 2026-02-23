#!/usr/bin/env python
from abc import ABC, abstractmethod


class CommandResolver(ABC):
    # Deferred resolvers run after all profiles have been checked for immediate resolvers.
    # This ensures real commands in ANY profile take priority over synthetic commands
    # (like ephemeral groups) that might shadow them.
    deferred = False

    @abstractmethod
    def _list_command_paths(self, parent, profile): ...

    @abstractmethod
    def _get_command(self, path, parent, profile): ...

    @abstractmethod
    def add_edition_hint(self, ctx, command, formatter): ...
