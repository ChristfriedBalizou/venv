"""This file is a command line interface to all sub functions
implemented in the venv
"""
import sys
import click

from typing import List

import venv.development as development  # pylint: disable=import-error
import venv.system as system  # pylint: disable=import-error
import venv.commons as utils  # pylint: disable=import-error


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
    multiple=True,
    help="User home path list"
)
@click.option(
    "--install",
    default=False,
    show_default=True,
    is_flag=True,
    help="Install system dependencies"
)
def profile(users: List[str], install: bool) -> None:
    """Configure user(s) profile with defaut base
    - bashrc
    - bash_aliases

    Arguments:
        users: to get the profile configuration
        install: if set to True install system packages otherwise no

    Return:
        void
    """
    for pw_dir in users:
        user = utils.User(pw_dir=pw_dir)
        print(f"{user.pw_name} profile", file=sys.stdout)

        print(f"Creating workspace directories", file=sys.stdout)
        assert development.create_directory(pw_dir, user.pw_name) is True

        print(f"Configuring profile", file=sys.stdout)
        development.profile(user)

        if install is False:
            return  # we stop here no more stuff to do

        packages = system.install_packages("fzf")
        assert len(packages) == 0, f"{user.pw_name} profile failed."


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
    multiple=True,
    help="User home path list"
)
@click.option(
    "-d",
    "--dependencies",
    default=[],
    multiple=True,
    help="System packages"
)
def vim(path, users, dependencies) -> None:
    """Configure VI(M) as your IDE.

    Arguments:
        path: to vim runtime shared directory
        users: to get the vimrc configuration
        dependencies: to be install on system before vim configuration

    Return:
        void
    """
    for pw_dir in users:
        user = utils.User(pw_dir=pw_dir)
        print(f"{user.pw_name} vim", file=sys.stdout)

        # Install system required packages
        errors = []

        if dependencies:
            errors = system.install_packages(*dependencies)

        assert len(errors) == 0, f"Vim failed: {errors!r}"
        development.vim(path, user)


developer.add_command(profile)
developer.add_command(vim)


if __name__ == "__main__":
    developer()
