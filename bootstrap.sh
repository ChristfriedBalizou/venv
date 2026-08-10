#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_REPO_ROOT="$REPO_ROOT"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

install_python() {
  if command -v python3 >/dev/null 2>&1 && \
    python3 -c 'import sys, venv; raise SystemExit(sys.version_info < (3, 9))'; then
    return
  fi

  if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
    printf 'ERROR: Python 3.9+ with venv is required; passwordless sudo is unavailable\n' >&2
    return 1
  fi

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install --yes python3 python3-venv
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y python3 python3-pip
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y python3 python3-pip
  else
    printf 'ERROR: no supported package manager can install Python\n' >&2
    return 1
  fi
}

install_python

if [ ! -x "$REPO_ROOT/.venv/bin/python" ]; then
  if [ -d "$REPO_ROOT/.venv" ]; then
    python3 -m venv --clear "$REPO_ROOT/.venv"
  else
    python3 -m venv "$REPO_ROOT/.venv"
  fi
fi

"$REPO_ROOT/.venv/bin/python" -m pip install \
  --disable-pip-version-check \
  --require-hashes \
  --requirement "$REPO_ROOT/requirements.txt"

PYTHONPATH="$REPO_ROOT/src" \
  "$REPO_ROOT/.venv/bin/python" -m dotfiles_installer.cli
