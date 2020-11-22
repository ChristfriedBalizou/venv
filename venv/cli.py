"""This file is a command line interface to all sub functions
implemented in the venv
"""
import pwd
import sys
import click

import development  # pylint: disable=import-error
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
        assert development.create_directory(user.pw_dir, username) is True
        assert development.profile(user) is True, f"{username} profile failed."


@click.command("vim")
@click.option(
    "-p",
    "--path",
    type=click.Path(),
    default=development.VIMRC_DIRECTORY,
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
    default=list(development.PACKAGES),  # Documentation lied. Click==7.0
    show_default=True,
    multiple=True,
    help="System packages"
)
def vim(path, users, dependencies):
    """Configure VI(M) as your IDE.
    """

    for username in users:
        user = pwd.getpwnam(username)

        # Install system required packages
        errors = system.install_packages(requirements)
        if errors.count:
            print(repr(errors), file=sys.stderr)
            sys.exit(1)

        development.vim(path, username)


developer.add_command(profile)
developer.add_command(vim)
