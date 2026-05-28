#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MISE_INSTALL_URL="${MISE_INSTALL_URL:-https://mise.run}"

main() {
  if has mise; then
    success "mise already installed"
    return 0
  fi

  if [ -x "$HOME/.local/bin/mise" ]; then
    success "mise already installed in ~/.local/bin"
    return 0
  fi

  if ! has curl; then
    error "curl is required to install mise"
    return 1
  fi

  info "installing mise for current user"
  retry 3 sh -c "curl -fsSL '$MISE_INSTALL_URL' | sh"

  if [ -x "$HOME/.local/bin/mise" ] || has mise; then
    success "mise installed"
  else
    error "mise install completed but mise was not found"
    return 1
  fi
}

main "$@"
