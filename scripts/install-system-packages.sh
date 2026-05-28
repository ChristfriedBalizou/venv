#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

APT_PACKAGES=(
  bash
  ca-certificates
  curl
  git
  tmux
  unzip
  zip
  build-essential
  cmake
  fonts-powerline
  ripgrep
  shellcheck
  shfmt
  fzf
)

APT_EDITOR_FALLBACKS=(
  vim
  vim-nox
  neovim
)

DNF_PACKAGES=(
  bash
  ca-certificates
  curl
  git
  tmux
  unzip
  zip
  gcc
  gcc-c++
  make
  cmake
  powerline-fonts
  ripgrep
  ShellCheck
  shfmt
  fzf
)

DNF_EDITOR_FALLBACKS=(
  vim-enhanced
  vim
  neovim
)

install_with_apt() {
  info "installing optional system packages with apt"
  retry 3 sudo apt-get update
  retry 3 sudo apt-get install --yes "${APT_PACKAGES[@]}"
  install_first_available apt-get "${APT_EDITOR_FALLBACKS[@]}"
}

install_with_dnf() {
  info "installing optional system packages with dnf"
  retry 3 sudo dnf install -y "${DNF_PACKAGES[@]}"
  install_first_available dnf "${DNF_EDITOR_FALLBACKS[@]}"
}

install_with_yum() {
  info "installing optional system packages with yum"
  retry 3 sudo yum install -y "${DNF_PACKAGES[@]}"
  install_first_available yum "${DNF_EDITOR_FALLBACKS[@]}"
}

package_installed() {
  local manager="$1"
  local package="$2"

  case "$manager" in
    apt-get)
      dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"
      ;;
    dnf | yum)
      rpm -q "$package" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

install_package() {
  local manager="$1"
  local package="$2"

  case "$manager" in
    apt-get)
      retry 3 sudo apt-get install --yes "$package"
      ;;
    dnf)
      retry 3 sudo dnf install -y "$package"
      ;;
    yum)
      retry 3 sudo yum install -y "$package"
      ;;
    *)
      return 1
      ;;
  esac
}

install_first_available() {
  local manager="$1"
  shift

  local package
  for package in "$@"; do
    if package_installed "$manager" "$package"; then
      success "editor package already installed: $package"
      return 0
    fi
  done

  for package in "$@"; do
    if install_package "$manager" "$package"; then
      success "editor package installed: $package"
      return 0
    fi
    warn "editor package unavailable or failed: $package"
  done

  warn "no editor package fallback could be installed"
}

main() {
  if ! has sudo; then
    warn "sudo not found; skipping optional system packages"
    return 0
  fi

  if ! sudo -n true >/dev/null 2>&1; then
    warn "sudo is not available without a prompt; skipping optional system packages"
    return 0
  fi

  local os_id
  os_id="$(detect_os)"

  case "$os_id" in
    debian | ubuntu | raspbian | raspberrypi)
      install_with_apt || warn "apt package installation failed; continuing with user-space tools"
      ;;
    fedora | rhel | centos)
      if has dnf; then
        install_with_dnf || warn "dnf package installation failed; continuing with user-space tools"
      elif has yum; then
        install_with_yum || warn "yum package installation failed; continuing with user-space tools"
      else
        warn "no supported package manager found for $os_id"
      fi
      ;;
    *)
      warn "unsupported OS '$os_id'; skipping optional system packages"
      ;;
  esac

  success "system package step complete"
}

main "$@"
