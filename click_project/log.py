#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import collections
import re
import logging

import click
import click_log
import six

from click_project.click_helpers import click_get_current_context_safe
from click_project import completion


class DevelopColorFormatter(click_log.core.ColorFormatter):
    """A click log formatter with augmented output, to be used in debug mode"""
    def format(self, record):
        if not record.exc_info:
            level = record.levelname.lower()
            prefix = click.style('{}({}): {}: '.format(record.name, record.lineno, level), **self.colors.get(level, {}))
            record.msg = '\n'.join(prefix + x for x in str(record.msg).splitlines())
        return logging.Formatter.format(self, record)


class LogLevelExitException(BaseException):
    def __init__(self):
        message = "Aborting because log level greater than {}".format(exit_on_log_level)
        super(LogLevelExitException, self).__init__(message)


exit_on_log_level = None


class Handler(logging.Handler):
    """click-project log handler

    It puts everything in the error output. Also, it allow to exit abruptly when
    a log of some level is issued"""
    def emit(self, record):
        if completion.IN_COMPLETION and record.levelno < 40:
            return
        try:
            msg = self.format(record)
            click.echo(msg, err=True)
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handleError(record)
        if (
                exit_on_log_level is not None and
                record.levelno >= nameToLevel[exit_on_log_level.upper()]
        ):
            raise LogLevelExitException()


default_handler = Handler()
default_handler.setLevel(logging.INFO)
default_handler.formatter = click_log.ColorFormatter()


def basic_config(logger=None):
    """Set up the default handler (:py:class:`Handler`) and formatter
    (:py:class:`ColorFormatter`) on the given logger."""
    if not isinstance(logger, logging.Logger):
        logger = logging.getLogger(logger)
    logger.handlers = [default_handler]
    logger.propagate = False
    logger.setLevel(1)

    return logger


def get_logger(name):
    if name.startswith("pluginbase."):
        name = name.replace("_", "|")
        name = re.sub("^pluginbase\.\|internalspace.[^.]+\.", "click_project.plugins.", name)
        name = name.replace("|", "_")
    return logging.getLogger(name)


LOGGER = get_logger(__name__)


def getLogger(name):
    LOGGER.deprecated("getLogger is deprecated. Please use get_logger instead")
    return get_logger(name)


DEVELOP = 5
if six.PY3:
    logging._levelToName[DEVELOP] = "DEVELOP"
    logging._nameToLevel["DEVELOP"] = DEVELOP
    nameToLevel = logging._nameToLevel
else:
    logging._levelNames[DEVELOP] = 'DEVELOP'
    logging._levelNames['DEVELOP'] = DEVELOP
    nameToLevel = logging._levelNames
DevelopColorFormatter.colors["develop"] = DevelopColorFormatter.colors["debug"]


def develop(self, msg, *args, **kwargs):
    if self.isEnabledFor(DEVELOP):
        self._log(DEVELOP, msg, args, **kwargs)


logging.Logger.develop = develop


ACTION = 15
if six.PY3:
    logging._levelToName[ACTION] = "ACTION"
    logging._nameToLevel["ACTION"] = ACTION
    nameToLevel = logging._nameToLevel
else:
    logging._levelNames[ACTION] = 'ACTION'
    logging._levelNames['ACTION'] = ACTION
    nameToLevel = logging._levelNames
DevelopColorFormatter.colors["action"] = dict(fg='green')


# set dry_run to True to put the action log in stdout instead of the usual logger output
dry_run = False


def action(self, msg, *args, **kwargs):
    from click_project import lib
    if lib.dry_run:
        click.echo("(dry-run) {}".format(msg))
    elif self.isEnabledFor(ACTION):
        self._log(ACTION, msg, args, **kwargs)


logging.Logger.action = action


STATUS = 17
if six.PY3:
    logging._levelToName[STATUS] = "STATUS"
    logging._nameToLevel["STATUS"] = STATUS
    nameToLevel = logging._nameToLevel
else:
    logging._levelNames[STATUS] = 'STATUS'
    logging._levelNames['STATUS'] = STATUS
    nameToLevel = logging._levelNames
# don't register the colors dict in order to avoid the 'status: ' prefix


def status(self, msg, *args, **kwargs):
    if self.isEnabledFor(STATUS):
        self._log(STATUS, msg, args, **kwargs)


logging.Logger.status = status


DEPRECATED = 18
if six.PY3:
    logging._levelToName[DEPRECATED] = "DEPRECATED"
    logging._nameToLevel["DEPRECATED"] = DEPRECATED
    nameToLevel = logging._nameToLevel
else:
    logging._levelNames[DEPRECATED] = 'DEPRECATED'
    logging._levelNames['DEPRECATED'] = DEPRECATED
    nameToLevel = logging._levelNames
DevelopColorFormatter.colors["deprecated"] = dict(fg='magenta')


def deprecated(self, msg, *args, **kwargs):
    if self.isEnabledFor(DEPRECATED):
        self._log(DEPRECATED, msg, args, **kwargs)


logging.Logger.deprecated = deprecated


DEBUG = logging.DEBUG
INFO = logging.INFO
WARN = logging.WARN
WARNING = logging.WARNING
ERROR = logging.ERROR
LOG_LEVELS = collections.OrderedDict(
    [
        ("develop", DEVELOP),
        ("debug", logging.DEBUG),
        ("action", ACTION),
        ("status", STATUS),
        ("deprecated", DEPRECATED),
        ("info", logging.INFO),
        ("warning", logging.WARNING),
        ("error", logging.ERROR),
        ("critical", logging.CRITICAL)
    ]
)
