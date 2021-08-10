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
import shutil
from subprocess import PIPE, check_output, call

from git import Repo
from lincl import sed

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
    "fonts-powerline",
)  # Debian base package to install


PLUGINS = (
    ("master", "https://github.com/mattn/emmet-vim.git"),
    ("master", "https://github.com/preservim/tagbar.git"),
    ("master", "https://github.com/vim-airline/vim-airline.git"),
    ("master", "https://github.com/vim-airline/vim-airline-themes.git"),
    ("0.10.0", "https://github.com/davidhalter/jedi-vim.git"),
    ("master", "https://github.com/psf/black.git"),
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
def vim(vimrc: str, user: utils.User) -> None:
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

    for (branch, repository) in PLUGINS:
        name = os.path.basename(repository)
        destination = os.path.join(vimrc, "my_plugins", name)

        if os.path.exists(destination):
            print(f"Plugin {name} already cloned.", file=sys.stdout)
            continue

        print(f"Cloning plugin {name} repo.", file=sys.stdout)
        Repo.clone_from(
            repository,
            destination,
            depth=1,
            branch=branch,
            recurse_submodules=True
        )

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
def profile(user: utils.User) -> bool:
    """This function will apply the same profile(bashrc)
    shortcuts and function.

    Arguments:
        user: User getting the profile configuration

    Return:
        True is everything went fine otherwise False
    """

    # 1. Install Oh My Bash
    # https://github.com/ohmybash/oh-my-bash
    bashrcfile = os.path.join(user.pw_dir, ".bashrc")

    if not os.path.exists(f"{bashrcfile}.omb"):
        ohmybash = os.path.join(BASE_DIRECTORY, "venv", "oh-my-bash.sh")
        with open(ohmybash, "rb") as buff:
            call(buff.read(), shell=True)
        sed("-i", "/OSH_THEME/c\\OSH_THEME='agnoster'", f"{bashrcfile}.omb")

    # 2. Create default basrch file
    for bash in ("bashrc", "bash_aliases"):
        bashfile = os.path.join(user.pw_dir, f".{bash}")

        shutil.copy(os.path.join(BASE_DIRECTORY, "venv", bash), bashfile)
        shutil.chown(bashfile, user=user.pw_name)

    # 3. Download powerline fonts
    fonts = os.path.join(user.pw_dir, ".fonts")

    if not os.path.exists(fonts):
        Repo.clone_from(
            "https://github.com/powerline/fonts.git",
            fonts,
            depth=1
        )

        current_pwd = os.getcwd()

        os.chdir(fonts)
        call("./install.sh")
        os.chdir(current_pwd)

    # 4. Install and setup fzf
    fzf = os.path.join(user.pw_dir, ".fzf")

    if not os.path.exists(fzf):
        Repo.clone_from(
            "https://github.com/junegunn/fzf.git",
            fzf,
            depth=1
        )

        call(os.path.join(fzf, "install"))
