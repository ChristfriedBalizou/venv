#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

finish() {
  local status="$?"
  print_summary

  if [ "$status" -eq 0 ]; then
    notify "venv setup complete" "Development environment installed for $USER."
  else
    notify "venv setup failed" "See $VENV_LOG_FILE for details."
  fi

  exit "$status"
}

trap finish EXIT

main() {
  info "starting current-user setup for $USER"
  info "repo: $VENV_REPO_ROOT"

  "$VENV_REPO_ROOT/scripts/create-workspace.sh"
  "$VENV_REPO_ROOT/scripts/install-system-packages.sh"
  "$VENV_REPO_ROOT/scripts/install-mise.sh"
  "$VENV_REPO_ROOT/scripts/install-tools.sh"
  "$VENV_REPO_ROOT/scripts/install-bash.sh"
  "$VENV_REPO_ROOT/scripts/link-dotfiles.sh"
  "$VENV_REPO_ROOT/scripts/install-fzf.sh"
  "$VENV_REPO_ROOT/scripts/install-vim.sh"

  success "current-user setup complete"
}

main "$@"
