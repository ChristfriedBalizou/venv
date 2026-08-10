#!/usr/bin/env bash

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    BLUE="$(tput setaf 4)"
    NORMAL="$(tput sgr0)"
  else
    BLUE=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  # Checks the minium version of bash (v4) installed,
  # stops the installation if check fails
  if [ -n "$BASH_VERSION" ]; then
    bash_major_version="${BASH_VERSION%%.*}"
    if [ "$bash_major_version" -lt 4 ]; then
      printf "Error: Bash 4 required for Oh My Bash.\n"
      printf "Error: Upgrade Bash and try again.\n"
      exit 1
    fi
  fi

  if [ -z "${OSH:-}" ]; then
    OSH="$HOME/.oh-my-bash"
  fi

  if [ -d "$OSH" ]; then
    case "$OSH" in
      "$HOME"/*) rm -rf "$OSH" ;;
      *)
        printf 'Error: refusing to replace Oh My Bash outside HOME: %s\n' "$OSH" >&2
        exit 1
        ;;
    esac
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf '%sCloning Oh My Bash...%s\n' "$BLUE" "$NORMAL"
  hash git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit >/dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git "$OSH" || {
    printf "Error: git clone of oh-my-bash repo failed\n"
    exit 1
  }

  printf '%sUsing the Oh My Bash template file and adding it to ~/.bashrc%s\n' "$BLUE" "$NORMAL"
  cp "$OSH/templates/bashrc.osh-template" "$HOME/.bashrc.omb"
  sed "/^export OSH=/ c\\
export OSH=$OSH
  " "$HOME/.bashrc.omb" >"$HOME/.bashrc-ombtemp"
  mv -f "$HOME/.bashrc-ombtemp" "$HOME/.bashrc.omb"
}

main
