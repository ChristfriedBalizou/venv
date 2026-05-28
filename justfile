set dotenv-load := true
set export := true

repo := justfile_directory()

default:
    @just --list

install:
    @{{repo}}/scripts/install.sh

bootstrap:
    @{{repo}}/bootstrap.sh

dry-run:
    @VENV_DRY_RUN=1 {{repo}}/scripts/install.sh

check:
    @bash -n {{repo}}/bootstrap.sh {{repo}}/scripts/*.sh
    @if command -v shellcheck >/dev/null 2>&1; then shellcheck {{repo}}/bootstrap.sh {{repo}}/scripts/create-workspace.sh {{repo}}/scripts/install-*.sh {{repo}}/scripts/lib.sh {{repo}}/scripts/link-dotfiles.sh; else echo "WARN shellcheck not installed"; fi

fmt:
    @if command -v shfmt >/dev/null 2>&1; then shfmt -w {{repo}}/bootstrap.sh {{repo}}/scripts/*.sh; else echo "WARN shfmt not installed"; fi

clean-state:
    @rm -rf "$HOME/.local/state/venv"
