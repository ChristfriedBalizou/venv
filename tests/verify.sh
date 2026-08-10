#!/usr/bin/env bash

set -Eeuxo pipefail

: "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must identify the installed repository}"

test -d "$HOME/src/data"
test -d "$HOME/src/tools"
test -d "$HOME/src/github.com"

test "$(readlink "$HOME/.bashrc")" = "$DOTFILES_REPO_ROOT/dotfiles/bash/.bashrc"
test "$(readlink "$HOME/.blerc")" = "$DOTFILES_REPO_ROOT/dotfiles/bash/.blerc"
test "$(readlink "$HOME/.tmux.conf")" = "$DOTFILES_REPO_ROOT/dotfiles/tmux/.tmux.conf"
test "$(readlink "$HOME/.vimrc")" = "$DOTFILES_REPO_ROOT/dotfiles/vim/.vimrc"
test "$(readlink "$HOME/.config/nvim/init.vim")" = "$DOTFILES_REPO_ROOT/dotfiles/nvim/.config/nvim/init.vim"

test -x "$HOME/.local/bin/mise"
test -x "$DOTFILES_REPO_ROOT/.venv/bin/python"
test "$("$DOTFILES_REPO_ROOT/.venv/bin/python" -c 'import lincl; print(lincl.__version__)')" = "2.0.0"
test "$("$HOME/.local/bin/mise" --version | awk 'NR == 1 { print $1 }')" = "2026.7.13"
test -d "$HOME/.oh-my-bash"
test -f "$HOME/.bashrc.omb"
test -f "$HOME/.local/share/blesh/ble.sh"
test "$(<"$HOME/.local/share/blesh/.dotfiles-version")" = "0.4.0-devel3"

command -v fzf >/dev/null
command -v just >/dev/null
command -v rg >/dev/null
command -v shellcheck >/dev/null
command -v shfmt >/dev/null
command -v tmux >/dev/null
command -v vim >/dev/null

vim_version="$(vim --version | sed -nE '1s/.* ([0-9]+)\..*/\1/p')"
test "$vim_version" -ge 8
vim --clean --not-a-term --noplugin -Nu "$HOME/.vimrc" -es +qall

test "$(git config --global core.editor)" = vim
bash -n "$HOME/.bashrc" "$HOME/.blerc"
