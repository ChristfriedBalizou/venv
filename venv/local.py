"""This file will setup your local developer environment
The listed function aim to install and setup:
    - Install Getting started package:
        * git
        * tig
        * vim-nox
        * ctags
        * cmake
        * npm
        * pip
    - Working directories:
        * ~/src
        * ~/src/data
        * ~/src/github.com
    - Setup your vim and plugins
    - Setup your bashrc and profile
"""
import os
import shutil
import getpass
from typing import List
from subprocess import PIPE, check_output

from git import Repo

import system
import commons as utils


BASE_DIRECTORY = os.path.realpath(os.path.dirname(os.path.dirname(__file__)))

PACKAGES = (
    "git",
    "tig",
    "vim-nox",
    "exuberant-ctags",
    "cmake",
    "npm",
    "python-pip",
    "python3-pip",
)  # Debian base package to install


PLUGINS = (
    "https://github.com/mattn/emmet-vim.git",
    "https://github.com/python-mode/python-mode.git",
    "https://github.com/psf/black.git",
)  # Custom vim plugins to install


@utils.crash_false
def create_directory(directory, user=getpass.getuser()) -> bool:
    """Will create a given directory
    and chown the given user if not None
    Otherwise to the user running this
    script

    Arguments:
        directory: a directory path
        user: user to chown the directory too

    Return:
        boolean True if "OK" False if not
    """
    os.makedirs(directory, exist_ok=True)
    shutil.chown(directory, user=user)
    return True


@utils.crash_traceback
def vim(directory: str, users: List[str]) -> None:
    """This function goal is to configure vim
    and setup our vim as an IDE.

    1- Clone the vimrc base comfig from
       https://github.com/amix/vimrc

    2- Clone my plugins to destination/my_plugins

    3- Move configs.vim to destination/my_configs.vim

    Arguments:
        directory: Directory where all vim configuration will
                   move to. This is useful to cross use the same
                   configuration for all users.
    Return:
        void
    """
    vimrc = os.path.join(directory, "vimrc.runtime")

    if not os.path.exists(vimrc):
        Repo.clone_from(
            "https://github.com/amix/vimrc.git",
            vimrc,
            depth=1
        )  # Clone base vimrc config from amix

    for plugin in PLUGINS:
        destination = os.path.join(
            vimrc,
            "my_plugins",
            os.path.basename(plugin)
        )

        if os.path.exists(destination):
            continue

        Repo.clone_from(plugin, destination, depth=1)

    shutil.copy(
        os.path.join(BASE_DIRECTORY, "venv", "configs.vim"),
        os.path.join(vimrc, "my_configs.vim")
    )

    command = (
        "bash",
        os.path.join(vimrc, "install_awesome_parameterized.sh"),
        vimrc,
        *users
    )

    check_output(command, universal_newlines=True, stderr=PIPE)


@utils.crash_false
def profile(users: List[str]) -> bool:
    """This function will apply the same profile(bashrc)
    shortcuts and function.

    Arguments:
        users: List of users getting the profile configuration

    Return:
        True is everything went fine otherwise False
    """
    home = os.path.join("/", "home")

    for user in users:

        if not os.path.exists(os.path.join(home, user)):
            continue

        for bash in ("bashrc", "bash_aliases"):
            bashfile = os.path.join(home, user, f".{bash}")

            shutil.copy(os.path.join(BASE_DIRECTORY, "venv", bash), bashfile)
            shutil.chown(bashfile, user=user)

    return system.install(system.PackageQuery(name="fzf")) is None
