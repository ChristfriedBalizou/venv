#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  info "configuring git defaults"

  if ! has git; then
    warn "git not found; skipping git defaults"
    return 0
  fi

  run git config --global core.editor vim
  success "configured git core.editor=vim"
}

main "$@"
