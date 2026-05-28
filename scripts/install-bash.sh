#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  info "installing bash enhancements"

  if [ ! -f "$HOME/.bashrc.omb" ]; then
    if [ "$VENV_DRY_RUN" = "1" ]; then
      info "dry-run: install Oh My Bash"
    else
      OSH="$HOME/.oh-my-bash" bash "$VENV_REPO_ROOT/scripts/oh-my-bash.sh" --unattended >>"$VENV_LOG_FILE" 2>&1 || warn "Oh My Bash install failed; continuing"
      if [ -f "$HOME/.bashrc.omb" ]; then
        sed -i "s/^OSH_THEME=.*/OSH_THEME='agnoster'/" "$HOME/.bashrc.omb" || true
      fi
    fi
  else
    success "Oh My Bash already configured"
  fi

  local mise_activation
  # shellcheck disable=SC2016
  mise_activation='if [ -x "$HOME/.local/bin/mise" ]; then eval "$("$HOME/.local/bin/mise" activate bash)"; fi'

  append_once "$HOME/.profile" "# venv mise activation" "$mise_activation"
  append_once "$HOME/.bash_profile" "# venv mise activation" "$mise_activation"

  success "bash enhancement step complete"
}

main "$@"
