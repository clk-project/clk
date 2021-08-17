#!/usr/bin/env python
# -*- coding: utf-8 -*-

import collections
import logging
import re

import click
import click_log


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
        message = 'Aborting because log level greater than {}'.format(exit_on_log_level)
        super(LogLevelExitException, self).__init__(message)


exit_on_log_level = None


class Handler(logging.Handler):
    """clk log handler

    It puts everything in the error output. Also, it allow to exit abruptly when
    a log of some level is issued"""
    def emit(self, record):
        from clk import completion
        if completion.IN_COMPLETION and record.levelno < 40:
            return
        try:
            msg = self.format(record)
            click.echo(msg, err=True)
        except (KeyboardInterrupt, SystemExit):
            raise
        except BaseException:
            self.handleError(record)
        if (exit_on_log_level is not None and record.levelno >= LOG_LEVELS[exit_on_log_level.lower()]):
            raise LogLevelExitException()


default_handler = Handler()
default_handler.formatter = click_log.ColorFormatter()

managed_loggers = set()


def basic_config(logger=None):
    """Set up the default handler (:py:class:`Handler`) and formatter
    (:py:class:`ColorFormatter`) on the given logger."""
    if not isinstance(logger, logging.Logger):
        logger = logging.getLogger(logger)
    logger.handlers = [default_handler]
    logger.propagate = False
    managed_loggers.add(logger)
    return logger


def set_level(level):
    for logger in managed_loggers:
        logger.setLevel(level)


def get_logger(name):
    # type: (str) -> Logger
    if name.startswith('pluginbase.'):
        name = re.sub(r'^pluginbase\._internalspace.[^.]+\.', 'clk.plugins.', name)
    return logging.getLogger(name)


LOGGER = get_logger(__name__)


def getLogger(name):
    # type: (str) -> Logger
    LOGGER.deprecated('getLogger is deprecated. Please use get_logger instead')
    return get_logger(name)


class Logger(logging.getLoggerClass()):
    def develop(self, msg, *args, **kwargs):
        if self.isEnabledFor(DEVELOP):
            self._log(DEVELOP, msg, args, **kwargs)

    def action(self, msg, *args, **kwargs):
        from clk import lib
        if lib.dry_run:
            click.echo('(dry-run) {}'.format(msg))
        elif self.isEnabledFor(ACTION):
            self._log(ACTION, msg, args, **kwargs)

    def status(self, msg, *args, **kwargs):
        if self.isEnabledFor(STATUS):
            self._log(STATUS, msg, args, **kwargs)

    def deprecated(self, msg, *args, **kwargs):
        if self.isEnabledFor(DEPRECATED):
            self._log(DEPRECATED, msg, args, **kwargs)


logging.setLoggerClass(Logger)

DEVELOP = 5
logging.addLevelName(DEVELOP, 'DEVELOP')
DevelopColorFormatter.colors['develop'] = DevelopColorFormatter.colors['debug']

ACTION = 15
logging.addLevelName(ACTION, 'ACTION')
DevelopColorFormatter.colors['action'] = dict(fg='green')

STATUS = 17
logging.addLevelName(STATUS, 'STATUS')
# don't register the colors dict in order to avoid the 'status: ' prefix

DEPRECATED = 18
logging.addLevelName(DEPRECATED, 'DEPRECATED')
DevelopColorFormatter.colors['deprecated'] = dict(fg='magenta')

DEBUG = logging.DEBUG
INFO = logging.INFO
WARN = logging.WARN
WARNING = logging.WARNING
ERROR = logging.ERROR
LOG_LEVELS = collections.OrderedDict([('develop', DEVELOP), ('debug', logging.DEBUG), ('action', ACTION),
                                      ('status', STATUS), ('deprecated', DEPRECATED), ('info', logging.INFO),
                                      ('warning', logging.WARNING), ('error', logging.ERROR),
                                      ('critical', logging.CRITICAL)])
