#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  info "creating workspace directories"

  local directories=(
    "$HOME/src"
    "$HOME/src/data"
    "$HOME/src/tools"
    "$HOME/src/github.com"
  )

  local directory
  for directory in "${directories[@]}"; do
    if [ "$DOTFILES_DRY_RUN" = "1" ]; then
      info "dry-run: mkdir -p $directory"
    else
      mkdir -p "$directory"
    fi
    success "workspace ready $directory"
  done
}

main "$@"
