#!/usr/bin/env bash

set -Eeuo pipefail

VENV_REPO_ROOT="${VENV_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
VENV_STATE_DIR="${VENV_STATE_DIR:-$HOME/.local/state/venv}"
VENV_LOG_FILE="${VENV_LOG_FILE:-$VENV_STATE_DIR/install.log}"
VENV_BACKUP_DIR="${VENV_BACKUP_DIR:-$VENV_STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)}"
VENV_SUMMARY_FILE="${VENV_SUMMARY_FILE:-$VENV_STATE_DIR/summary.$$.log}"
VENV_DRY_RUN="${VENV_DRY_RUN:-0}"

export VENV_REPO_ROOT
export VENV_STATE_DIR
export VENV_LOG_FILE
export VENV_BACKUP_DIR
export VENV_SUMMARY_FILE
export VENV_DRY_RUN

mkdir -p "$VENV_STATE_DIR"
touch "$VENV_LOG_FILE" "$VENV_SUMMARY_FILE"

if [ -t 1 ]; then
  VENV_RED="$(printf '\033[31m')"
  VENV_GREEN="$(printf '\033[32m')"
  VENV_YELLOW="$(printf '\033[33m')"
  VENV_BLUE="$(printf '\033[34m')"
  VENV_RESET="$(printf '\033[0m')"
else
  VENV_RED=""
  VENV_GREEN=""
  VENV_YELLOW=""
  VENV_BLUE=""
  VENV_RESET=""
fi

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log_line() {
  printf '[%s] %s\n' "$(timestamp)" "$*" >>"$VENV_LOG_FILE"
}

info() {
  printf '%s==>%s %s\n' "$VENV_BLUE" "$VENV_RESET" "$*"
  log_line "INFO $*"
}

success() {
  printf '%sOK%s %s\n' "$VENV_GREEN" "$VENV_RESET" "$*"
  log_line "OK $*"
  printf 'OK %s\n' "$*" >>"$VENV_SUMMARY_FILE"
}

warn() {
  printf '%sWARN%s %s\n' "$VENV_YELLOW" "$VENV_RESET" "$*" >&2
  log_line "WARN $*"
  printf 'WARN %s\n' "$*" >>"$VENV_SUMMARY_FILE"
}

error() {
  printf '%sERROR%s %s\n' "$VENV_RED" "$VENV_RESET" "$*" >&2
  log_line "ERROR $*"
  printf 'ERROR %s\n' "$*" >>"$VENV_SUMMARY_FILE"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  log_line "RUN $*"
  if [ "$VENV_DRY_RUN" = "1" ]; then
    info "dry-run: $*"
    return 0
  fi
  "$@" >>"$VENV_LOG_FILE" 2>&1
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

  local destination="$VENV_BACKUP_DIR/${path#"$HOME"/}"

  if [ "$VENV_DRY_RUN" = "1" ]; then
    info "dry-run: backup $path -> $destination"
    return 0
  fi

  mkdir -p "$VENV_BACKUP_DIR"
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

  if [ "$VENV_DRY_RUN" = "1" ]; then
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

  if [ "$VENV_DRY_RUN" = "1" ]; then
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
  if [ -s "$VENV_SUMMARY_FILE" ]; then
    sed 's/^/  /' "$VENV_SUMMARY_FILE"
  else
    printf '  No changes recorded.\n'
  fi
  info "log: $VENV_LOG_FILE"
}
