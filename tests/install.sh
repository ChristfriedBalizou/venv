#!/usr/bin/env bash

set -Eeuo pipefail

TEST_USER="dotfiles-test"
TEST_HOME="/home/$TEST_USER"
TEST_REPO="$TEST_HOME/dotfiles"
TEST_PATH="$TEST_HOME/.local/bin:$TEST_HOME/.local/share/mise/shims:$TEST_HOME/.fzf/bin:/usr/local/bin:/usr/bin:/bin"

install_test_prerequisites() {
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install --yes bash ca-certificates curl git sudo xz-utils
  elif command -v dnf >/dev/null 2>&1; then
    install_rpm_test_prerequisites dnf
  elif command -v yum >/dev/null 2>&1; then
    install_rpm_test_prerequisites yum
  else
    printf 'ERROR: unsupported test image\n' >&2
    return 1
  fi
}

install_rpm_test_prerequisites() {
  local manager="$1"
  local -a packages=(ca-certificates)
  local command package

  for command in bash curl git sudo xz useradd; do
    if command -v "$command" >/dev/null 2>&1; then
      continue
    fi

    case "$command" in
      useradd) package=shadow-utils ;;
      *) package="$command" ;;
    esac
    packages+=("$package")
  done

  "$manager" install --assumeyes "${packages[@]}"
}

create_test_user() {
  useradd --create-home --shell /bin/bash "$TEST_USER"
  printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$TEST_USER" >"/etc/sudoers.d/$TEST_USER"
  chmod 0440 "/etc/sudoers.d/$TEST_USER"

  cp -a /workspace "$TEST_REPO"
  chown -R "$TEST_USER:$TEST_USER" "$TEST_REPO"
}

run_as_test_user() {
  sudo --preserve-env=CI --user "$TEST_USER" env \
    HOME="$TEST_HOME" \
    PATH="$TEST_PATH" \
    TERM=xterm-256color \
    USER="$TEST_USER" \
    bash --noprofile --norc -c "$1"
}

verify_installation() {
  run_as_test_user "DOTFILES_REPO_ROOT='$TEST_REPO' bash '$TEST_REPO/tests/verify.sh'"
}

main() {
  install_test_prerequisites
  create_test_user

  run_as_test_user "cd '$TEST_REPO' && ./bootstrap.sh"
  verify_installation

  run_as_test_user "cd '$TEST_REPO' && just install"
  verify_installation

  run_as_test_user "cd '$TEST_REPO' && just dry-run"
}

main "$@"
