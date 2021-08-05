"""This file is a command line interface to all sub functions
implemented in the venv
"""
import sys
import click
import shutil

import venv.development as development  # pylint: disable=import-error
import venv.system as system # pylint: disable=import-error
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
def profile(users) -> None:
    """Configure user(s) profile with defaut base
    - bashrc
    - bash_aliases

    Arguments:
        users: to get the profile configuration

    Return:
        void
    """
    for pw_dir in users:
        user = utils.User(pw_dir=pw_dir)
        print(f"{user.pw_name} profile", file=sys.stdout)

        print(f"Creating workspace directories", file=sys.stdout)
        assert development.create_directory(pw_dir, user.pw_name) is True

        print(f"Configuring profile", file=sys.stdout)
        assert development.profile(user) is True, f"{user.pw_name} profile failed."


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
    default=list(development.PACKAGES),  # Documentation lied. Click==7.0
    show_default=True,
    multiple=True,
    help="System packages"
)
@click.option(
    "--force",
    default=False,
    show_default=True,
    is_flag=True,
    help="Uinstall and install"
)
def vim(path, users, dependencies, force) -> None:
    """Configure VI(M) as your IDE.

    Arguments:
        path: to vim runtime shared directory
        users: to get the vimrc configuration
        dependencies: to be install on system before vim configuration
        force: delete vim runtin shared directory

    Return:
        void
    """

    if force is True:
        shutil.rmtree(path, ignore_errors=True)

    for pw_dir in users:
        user = utils.User(pw_dir=pw_dir)
        print(f"{user.pw_name} vim", file=sys.stdout)

        # Install system required packages
        errors = system.install_packages(*dependencies)
        if len(errors):
            print(f"Vim failed: {errors!r}", file=sys.stderr)
            sys.exit(1)

        development.vim(path, user)


developer.add_command(profile)
developer.add_command(vim)


if __name__ == "__main__":
    developer()
