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
import sys
import pwd
import shutil
from subprocess import PIPE, check_output

from git import Repo

import venv.system as system
import venv.commons as utils


BASE_DIRECTORY = os.path.realpath(os.path.dirname(os.path.dirname(__file__)))

VIMRC_DIRECTORY = os.path.join("/", "opt", "vimrc.runtime")

DIRECTORIES = (
    os.path.join("src", "data"),
    os.path.join("src", "tools"),
    os.path.join("src", "github.com"),
)  # Workspace directories

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
    "https://github.com/Shougo/neocomplete.vim.git",
    "https://github.com/preservim/tagbar.git",
)  # Custom vim plugins to install


@utils.crash_false
def create_directory(base: str, username: str) -> bool:
    """Will create a given directory
    and chown the given username.

    Arguments:
        base: a directory path
        username: user to chown the directory too

    Return:
        boolean True if "OK" False if not
    """
    for directory in DIRECTORIES:
        path = os.path.join(base, directory)

        os.makedirs(path, exist_ok=True)
        shutil.chown(path, user=username)

    return True


@utils.crash_traceback
def vim(vimrc: str, user: pwd.struct_passwd) -> None:
    """This function goal is to configure vim
    and setup our vim as an IDE.

    1- Clone the vimrc base comfig from
       https://github.com/amix/vimrc

    2- Clone my plugins to destination/my_plugins

    3- Move configs.vim to destination/my_configs.vim

    Arguments:
        vimrc: Directory where all vim configuration will
               move to. This is useful to cross use the same
               configuration for all users.
        user: User getting the profile configuration

    Return:
        void
    """
    if not os.path.exists(vimrc):
        print("Cloning vimrc.git repo.", file=sys.stdout)
        Repo.clone_from(
            "https://github.com/amix/vimrc.git",
            vimrc,
            depth=1
        )  # Clone base vimrc config from amix

    for plugin in PLUGINS:
        name = os.path.basename(plugin)
        destination = os.path.join(vimrc, "my_plugins", name)

        if os.path.exists(destination):
            print(f"Plugin {name} already cloned.", file=sys.stdout)
            continue

        print(f"Cloning plugin {name} repo.", file=sys.stdout)
        Repo.clone_from(plugin, destination, depth=1, recurse_submodules=True)

    shutil.copy(
        os.path.join(BASE_DIRECTORY, "venv", "configs.vim"),
        os.path.join(vimrc, "my_configs.vim")
    )

    command = (
        shutil.which("bash"),
        os.path.join(vimrc, "install_awesome_parameterized.sh"),
        vimrc,
        user.pw_name
    )

    check_output(command, universal_newlines=True, stderr=PIPE)

    try:
        shutil.copyfile(
            os.path.join(user.pw_dir, ".myvimrc"),
            os.path.join(user.pw_dir, ".vimrc")
        )
    except Exception:
        pass


@utils.crash_false
def profile(user: pwd.struct_passwd) -> bool:
    """This function will apply the same profile(bashrc)
    shortcuts and function.

    Arguments:
        user: User getting the profile configuration

    Return:
        True is everything went fine otherwise False
    """
    for bash in ("bashrc", "bash_aliases"):
        bashfile = os.path.join(user.pw_dir, f".{bash}")

        shutil.copy(os.path.join(BASE_DIRECTORY, "venv", bash), bashfile)
        shutil.chown(bashfile, user=user.pw_name)

    return len(system.install_packages("fzf")) is 0
