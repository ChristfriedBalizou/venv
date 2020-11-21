"""This file contains cross module functions
"""
import sys
import contextlib
import traceback


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
