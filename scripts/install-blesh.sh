#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BLESH_VERSION="0.4.0-devel3"
BLESH_SHA256="c8612ee612bc6b10dbfd6e85c6cbdfd7caf152a12d1f9de22ea0a9d735b3080c"
BLESH_URL="https://github.com/akinomyoga/ble.sh/releases/download/v${BLESH_VERSION}/ble-${BLESH_VERSION}.tar.xz"
BLESH_INSTALL_DIR="$HOME/.local/share/blesh"
BLESH_TEMP_DIR=""

cleanup() {
  if [ -n "$BLESH_TEMP_DIR" ] && [ -d "$BLESH_TEMP_DIR" ]; then
    rm -rf "$BLESH_TEMP_DIR"
  fi
}

trap cleanup EXIT

verify_checksum() {
  local archive="$1"

  if has sha256sum; then
    printf '%s  %s\n' "$BLESH_SHA256" "$archive" | sha256sum --check --status
  elif has shasum; then
    printf '%s  %s\n' "$BLESH_SHA256" "$archive" | shasum --algorithm 256 --check --status
  else
    error "neither sha256sum nor shasum is available"
    return 1
  fi
}

main() {
  local version_file="$BLESH_INSTALL_DIR/.dotfiles-version"

  if [ -f "$BLESH_INSTALL_DIR/ble.sh" ] &&
    [ -f "$version_file" ] &&
    [ "$(<"$version_file")" = "$BLESH_VERSION" ]; then
    success "ble.sh $BLESH_VERSION already installed"
    return 0
  fi

  if ! has curl && ! has wget; then
    warn "curl and wget are unavailable; skipping ble.sh"
    return 0
  fi

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: install ble.sh $BLESH_VERSION to $BLESH_INSTALL_DIR"
    return 0
  fi

  local archive extracted_dir
  BLESH_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-blesh.XXXXXX")"
  archive="$BLESH_TEMP_DIR/ble.tar.xz"
  extracted_dir="$BLESH_TEMP_DIR/ble-$BLESH_VERSION"

  info "downloading ble.sh $BLESH_VERSION"
  if has curl; then
    retry 3 curl -fsSL "$BLESH_URL" -o "$archive"
  else
    retry 3 wget -q "$BLESH_URL" -O "$archive"
  fi

  verify_checksum "$archive"
  tar -xJf "$archive" -C "$BLESH_TEMP_DIR"

  if [ ! -f "$extracted_dir/ble.sh" ]; then
    error "ble.sh archive has an unexpected layout"
    return 1
  fi

  printf '%s\n' "$BLESH_VERSION" >"$extracted_dir/.dotfiles-version"
  mkdir -p "$(dirname "$BLESH_INSTALL_DIR")"
  backup_path "$BLESH_INSTALL_DIR"
  mv "$extracted_dir" "$BLESH_INSTALL_DIR"

  success "installed ble.sh $BLESH_VERSION"
}

main "$@"
