#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MISE_VERSION="2026.7.13"
MISE_INSTALLER_URL="https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/install.sh"
MISE_INSTALLER_SHA256="7e24785cd242e1b5b1704cdd8d877058a5dbb8eb871605858612676b640fdd7b"

verify_sha256() {
  local file="$1"

  if has sha256sum; then
    printf '%s  %s\n' "$MISE_INSTALLER_SHA256" "$file" | sha256sum --check --status
  elif has shasum; then
    printf '%s  %s\n' "$MISE_INSTALLER_SHA256" "$file" | shasum --algorithm 256 --check --status
  else
    error "sha256sum or shasum is required to verify the mise installer"
    return 1
  fi
}

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

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: install mise v$MISE_VERSION to $HOME/.local/bin/mise"
    return 0
  fi

  local temporary_dir installer
  temporary_dir="$(mktemp -d)"
  installer="$temporary_dir/mise-install.sh"
  trap 'rm -rf "$temporary_dir"' RETURN

  info "installing mise for current user"
  retry 3 curl --fail --silent --show-error --location "$MISE_INSTALLER_URL" --output "$installer"

  if ! verify_sha256 "$installer"; then
    error "mise installer checksum verification failed"
    return 1
  fi

  MISE_VERSION="v$MISE_VERSION" MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer" >>"$DOTFILES_LOG_FILE" 2>&1

  if [ -x "$HOME/.local/bin/mise" ] || has mise; then
    success "mise installed"
  else
    error "mise install completed but mise was not found"
    return 1
  fi
}

main "$@"
