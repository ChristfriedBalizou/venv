#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

  if ! has mise; then
    if [ "$VENV_DRY_RUN" = "1" ]; then
      info "dry-run: mise install"
      success "tool installation preview complete"
      return 0
    fi
    error "mise is required before installing tools"
    return 1
  fi

  info "trusting repo mise config"
  retry 3 mise trust "$VENV_REPO_ROOT"

  info "installing mise tools"
  retry 3 mise install

  if has just; then
    success "just available"
  else
    warn "just was not found after mise install; bootstrap may need a new shell"
  fi

  success "tool installation complete"
}

main "$@"
