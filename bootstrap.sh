#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_REPO_ROOT="$REPO_ROOT"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
PYTHON_EXECUTABLE=""

find_python() {
  local candidate

  for candidate in python3.14 python3.13 python3.12 python3.11 python3.10 python3; do
    if command -v "$candidate" >/dev/null 2>&1 && \
      "$candidate" -c 'import sys, venv; raise SystemExit(sys.version_info < (3, 10))'; then
      PYTHON_EXECUTABLE="$(command -v "$candidate")"
      return
    fi
  done

  return 1
}

install_python() {
  if find_python; then
    return
  fi

  if ! command -v sudo >/dev/null 2>&1 || ! sudo -n true >/dev/null 2>&1; then
    printf 'ERROR: Python 3.10+ with venv is required; passwordless sudo is unavailable\n' >&2
    return 1
  fi

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install --yes python3 python3-venv
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y python3.11 python3.11-pip
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y python3.11 python3.11-pip
  else
    printf 'ERROR: no supported package manager can install Python\n' >&2
    return 1
  fi

  if ! find_python; then
    printf 'ERROR: package installation did not provide Python 3.10+ with venv\n' >&2
    return 1
  fi
}

install_python

if [ ! -x "$REPO_ROOT/.venv/bin/python" ] || \
  ! "$REPO_ROOT/.venv/bin/python" -c \
    'import sys; raise SystemExit(sys.version_info < (3, 10))'; then
  if [ -d "$REPO_ROOT/.venv" ]; then
    "$PYTHON_EXECUTABLE" -m venv --clear "$REPO_ROOT/.venv"
  else
    "$PYTHON_EXECUTABLE" -m venv "$REPO_ROOT/.venv"
  fi
fi

"$REPO_ROOT/.venv/bin/python" -m pip install \
  --disable-pip-version-check \
  --require-hashes \
  --requirement "$REPO_ROOT/requirements.txt"

PYTHONPATH="$REPO_ROOT/src" \
  "$REPO_ROOT/.venv/bin/python" -m dotfiles_installer.cli
