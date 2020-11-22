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
def developer():
    """Setup developer configuration:
    - Profile
    - Vim
    """


@click.command("profile")
@click.option(
    "-u",
    "--users",
    default=utils.real_users(),
    show_default=utils.real_users(),
    multiple=True,
    help="Username list"
)
def profile(users):
    """Configure user(s) profile with defaut base
    - bashrc
    - bash_aliases
    """
    for username in users:
        user = pwd.getpwnam(username)

        # setup profile
        assert local.profile(user) is True, f"{username} configuration failed."


@click.command("vim")
@click.option(
    "-p",
    "--path",
    type=click.Path(),
    default=local.VIMRC_DIRECTORY,
    show_default=True,
    help="Shared directory"
)
@click.option(
    "-u",
    "--users",
    default=utils.real_users(),
    show_default=utils.real_users(),
    multiple=True,
    help="Username list"
)
@click.option(
    "-d",
    "--dependencies",
    default=list(local.PACKAGES),  # Documentation lied. Click==7.0
    show_default=True,
    multiple=True,
    help="System packages"
)
def vim(path, users, dependencies):
    """Configure VI(M) as your IDE.
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

developer.add_command(profile)
developer.add_command(vim)
