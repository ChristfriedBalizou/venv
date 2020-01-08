#!/usr/bin/env bash
# *****************************************************************************
# This script will setup basic environment configuration
# the goal will be to download the venv from git and install 
# requirement to get starting with development:
#   - Install git
#   - Install vim-nox
#   - Create mandatory directories (github, src, data, tools, ...)
#   - Install vundle for vim plugin
#   - Pull venv and install vimrc and bashrc
#   - Install vimrc plugins
# *****************************************************************************
set -u


# *************************************
# Install System requirements
# *************************************
sudo apt-get --yes install git vim-nox exuberant-ctags python-pip python3-pip 

# *************************************
# Install python requirements
# *************************************
pip3 install --user black 

# *************************************
# Create mandatory directory
# *************************************

# /src
mkdir -p $HOME/src

# /src/github.com
mkdir -p $HOME/src/github.com

# /src/tools
mkdir -p $HOME/src/tools

# /src/data
mkdir -p $HOME/src/data


# *************************************
# Install vim environment and plugins
# *************************************
GIT_DIRECTORY="$HOME/src/github.com"

# vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# venv.git
VENV_DIRECTORY="$GIT_DIRECTORY/ChristfriedBalizou/venv.git"
git clone https://github.com/ChristfriedBalizou/venv.git $VENV_DIRECTORY

# Install Quick fuzzy "fzf"
FUZZY_DIRECTORY="$GIT_DIRECTORY/junegunn/fzf.git"
git clone --depth 1 https://github.com/junegunn/fzf.git $GIT_DIRECTORY/junegunn/fzf.git
bash $FUZZY_DIRECTORY/install

# Configure symlinks
ln -sf $VENV_DIRECTORY/vimrc $HOME/.vimrc
ln -sf $VENV_DIRECTORY/bashrc $HOME/.bashrc
ln -sf $VENV_DIRECTORY/bash_aliases $HOME/.bash_aliases

# Source environment through profile
if [ -f $HOME/.profile ]; then
    . $HOME/.profile
else
    . $HOME/.bash_profile
fi

# Install vim plugins
vim +PluginInstall +qall

clear
echo "********************************************"
echo "* All done, You are good to go."
echo "********************************************"
