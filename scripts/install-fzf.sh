#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  if has fzf; then
    success "fzf already available"
    return 0
  fi

  if ! has git; then
    warn "git not found; skipping fzf fallback install"
    return 0
  fi

  info "installing fzf fallback under ~/.fzf"
  if [ ! -d "$HOME/.fzf/.git" ]; then
    retry 3 git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || {
      warn "fzf clone failed"
      return 0
    }
  fi

  if [ -x "$HOME/.fzf/install" ]; then
    retry 3 "$HOME/.fzf/install" --key-bindings --completion --no-update-rc || warn "fzf install script failed"
  fi

  success "fzf fallback step complete"
}

main "$@"
