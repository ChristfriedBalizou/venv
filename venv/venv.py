"""This file is a command line interface to all sub functions
implemented in the venv
"""
import pwd
import sys
import click

import local  # pylint: disable=import-error
import system  # pylint: disable=import-error
import commons as utils  # pylint: disable=import-error


@click.group()
def cli():
    """main interface
    """


@click.command("local")
@click.option(
    "-u",
    "--users",
    default=utils.real_users(),
    show_default=utils.real_users(),
    multiple=True,
    help="Username list"
)
@click.option(
    "-p",
    "--path",
    default=local.VIMRC_DIRECTORY,
    show_default=True,
    help="Shared vimrc directory"
)
@click.option(
    "-r",
    "--requirements",
    default=local.PACKAGES,
    show_default=True,
    help="System packages"
)
def local_environment(path, users, requirements):
    """CLI installing local environment
    """

    for username in users:
        user = pwd.getpwnam(username)

        # Create directories
        local.directories(user.pw_dir, username)

        # Install system required packages
        errors = system.install_packages(requirements)
        if errors.count:
            print(repr(errors), file=sys.stderr)
            sys.exit(1)

        # setup vim
        local.vim(path, username)

        # setup profile
        local.profile(user)


cli.add_command(local_environment)
