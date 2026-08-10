#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  info "linking dotfiles for current user"

  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/bash/.bashrc" "$HOME/.bashrc"
  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/bash/.bash_aliases" "$HOME/.bash_aliases"
  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/bash/.blerc" "$HOME/.blerc"
  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/nvim/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"

  success "dotfile linking complete"
}

main "$@"
