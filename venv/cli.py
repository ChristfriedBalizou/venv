"""This file is a command line interface to all sub functions
implemented in the venv
"""
import pwd
import sys
import click
import shutil

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
def profile(users) -> None:
    """Configure user(s) profile with defaut base
    - bashrc
    - bash_aliases

    Arguments:
        users: to get the profile configuration

    Return:
        void
    """
    for username in users:
        print(f"{username} profile", file=sys.stdout)
        user = pwd.getpwnam(username)

        print(f"Creating workspace directories", file=sys.stdout)
        assert development.create_directory(user.pw_dir, username) is True

        print(f"Configuring profile", file=sys.stdout)
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

    for username in users:
        print(f"{username} vim", file=sys.stdout)

        # Install system required packages
        errors = system.install_packages(dependencies)
        if len(errors):
            print("Vim failed: {errors!r}", file=sys.stderr)
            sys.exit(1)

        development.vim(path, pwd.getpwnam(username))


developer.add_command(profile)
developer.add_command(vim)
