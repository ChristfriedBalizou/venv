#!/usr/bin/env bash

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_REPO_ROOT="$REPO_ROOT"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

"$REPO_ROOT/scripts/install.sh"
