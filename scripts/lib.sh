#!/usr/bin/env bash

set -Eeuo pipefail

DOTFILES_REPO_ROOT="${DOTFILES_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOTFILES_STATE_DIR="${DOTFILES_STATE_DIR:-$HOME/.local/state/dotfiles}"
DOTFILES_LOG_FILE="${DOTFILES_LOG_FILE:-$DOTFILES_STATE_DIR/install.log}"
DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$DOTFILES_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)}"
DOTFILES_SUMMARY_FILE="${DOTFILES_SUMMARY_FILE:-$DOTFILES_STATE_DIR/summary.$$.log}"
DOTFILES_DRY_RUN="${DOTFILES_DRY_RUN:-0}"

export DOTFILES_REPO_ROOT
export DOTFILES_STATE_DIR
export DOTFILES_LOG_FILE
export DOTFILES_BACKUP_DIR
export DOTFILES_SUMMARY_FILE
export DOTFILES_DRY_RUN

mkdir -p "$DOTFILES_STATE_DIR"
touch "$DOTFILES_LOG_FILE" "$DOTFILES_SUMMARY_FILE"

if [ -t 1 ]; then
  DOTFILES_RED="$(printf '\033[31m')"
  DOTFILES_GREEN="$(printf '\033[32m')"
  DOTFILES_YELLOW="$(printf '\033[33m')"
  DOTFILES_BLUE="$(printf '\033[34m')"
  DOTFILES_RESET="$(printf '\033[0m')"
else
  DOTFILES_RED=""
  DOTFILES_GREEN=""
  DOTFILES_YELLOW=""
  DOTFILES_BLUE=""
  DOTFILES_RESET=""
fi

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log_line() {
  printf '[%s] %s\n' "$(timestamp)" "$*" >>"$DOTFILES_LOG_FILE"
}

info() {
  printf '%s==>%s %s\n' "$DOTFILES_BLUE" "$DOTFILES_RESET" "$*"
  log_line "INFO $*"
}

success() {
  printf '%sOK%s %s\n' "$DOTFILES_GREEN" "$DOTFILES_RESET" "$*"
  log_line "OK $*"
  printf 'OK %s\n' "$*" >>"$DOTFILES_SUMMARY_FILE"
}

warn() {
  printf '%sWARN%s %s\n' "$DOTFILES_YELLOW" "$DOTFILES_RESET" "$*" >&2
  log_line "WARN $*"
  printf 'WARN %s\n' "$*" >>"$DOTFILES_SUMMARY_FILE"
}

error() {
  printf '%sERROR%s %s\n' "$DOTFILES_RED" "$DOTFILES_RESET" "$*" >&2
  log_line "ERROR $*"
  printf 'ERROR %s\n' "$*" >>"$DOTFILES_SUMMARY_FILE"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  log_line "RUN $*"
  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: $*"
    return 0
  fi
  "$@" >>"$DOTFILES_LOG_FILE" 2>&1
}

retry() {
  local attempts="$1"
  shift
  local delay=2
  local attempt=1

  while true; do
    if run "$@"; then
      return 0
    fi

    if [ "$attempt" -ge "$attempts" ]; then
      error "failed after $attempts attempts: $*"
      return 1
    fi

    warn "attempt $attempt failed: $*; retrying in ${delay}s"
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 2))
  done
}

detect_os() {
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf '%s\n' "${ID:-unknown}"
  else
    uname -s | tr '[:upper:]' '[:lower:]'
  fi
}

backup_path() {
  local path="$1"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return 0
  fi

  local destination="$DOTFILES_BACKUP_DIR/${path#"$HOME"/}"

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: backup $path -> $destination"
    return 0
  fi

  mkdir -p "$DOTFILES_BACKUP_DIR"
  mkdir -p "$(dirname "$destination")"
  mv "$path" "$destination"
  success "backed up $path"
}

safe_symlink() {
  local source="$1"
  local target="$2"

  if [ ! -e "$source" ]; then
    error "missing source: $source"
    return 1
  fi

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    success "already linked $target"
    return 0
  fi

  backup_path "$target"

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: ln -s $source $target"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  success "linked $target"
}

append_once() {
  local file="$1"
  local marker="$2"
  local text="$3"

  if [ -f "$file" ] && grep -Fq "$marker" "$file"; then
    success "already configured $file"
    return 0
  fi

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: append marker $marker to $file"
    return 0
  fi

  mkdir -p "$(dirname "$file")"
  printf '\n%s\n%s\n' "$marker" "$text" >>"$file"
  success "updated $file"
}

notify() {
  local title="$1"
  local message="$2"

  if has notify-send && [ -n "${DISPLAY:-}" ]; then
    notify-send "$title" "$message" >/dev/null 2>&1 || true
  fi

  if has terminal-notifier; then
    terminal-notifier -title "$title" -message "$message" >/dev/null 2>&1 || true
  fi
}

print_summary() {
  info "summary"
  if [ -s "$DOTFILES_SUMMARY_FILE" ]; then
    sed 's/^/  /' "$DOTFILES_SUMMARY_FILE"
  else
    printf '  No changes recorded.\n'
  fi
  info "log: $DOTFILES_LOG_FILE"
}
