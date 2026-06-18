#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

finish() {
  local status="$?"
  print_summary

  if [ "$status" -eq 0 ]; then
    notify "dotfiles setup complete" "Development environment installed for $USER."
  else
    notify "dotfiles setup failed" "See $DOTFILES_LOG_FILE for details."
  fi

  exit "$status"
}

trap finish EXIT

main() {
  info "starting current-user setup for $USER"
  info "repo: $DOTFILES_REPO_ROOT"

  "$DOTFILES_REPO_ROOT/scripts/create-workspace.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-system-packages.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-mise.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-tools.sh"
  "$DOTFILES_REPO_ROOT/scripts/configure-git.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-bash.sh"
  "$DOTFILES_REPO_ROOT/scripts/link-dotfiles.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-fzf.sh"
  "$DOTFILES_REPO_ROOT/scripts/install-vim.sh" || warn "vim setup failed; continuing"

  success "current-user setup complete"
}

main "$@"
