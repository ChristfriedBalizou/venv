"""This file contains cross module functions
"""
import os
import sys
import contextlib
import traceback

from dataclasses import dataclass


@dataclass
class User:
    """This class is implemented to mimic pwd.struct_passwd

    To make to code platform(centos, debian, ...) user should be created
    by the given home path.
    """
    pw_dir: str

    @property
    def pw_name(self):
        return os.path.basename(self.pw_dir)


def crash_false(func):
    """As the function say this decorator crash returning
    False when an exception is raised
    """
    @contextlib.wraps(func)
    def decorator(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except:  # pylint: disable=bare-except
            return False

    return decorator


def crash_traceback(func):
    """The following function will crash
    print out the exception traceback
    """
    @contextlib.wraps(func)
    def decorator(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as ex:
            traceback.print_exc(file=sys.stderr)
            raise ex

    return decorator
