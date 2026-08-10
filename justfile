set dotenv-load := true
set export := true

repo := justfile_directory()

default:
    @just --list

install:
    @PYTHONPATH={{repo}}/src {{repo}}/.venv/bin/python -m dotfiles_installer.cli

bootstrap:
    @{{repo}}/bootstrap.sh

dry-run:
    @DOTFILES_DRY_RUN=1 PYTHONPATH={{repo}}/src {{repo}}/.venv/bin/python -m dotfiles_installer.cli

check:
    @{{repo}}/.venv/bin/python -m pytest
    @{{repo}}/.venv/bin/pre-commit run --all-files

fmt:
    @{{repo}}/.venv/bin/black --line-length 79 --target-version py39 src tests
    @{{repo}}/.venv/bin/isort --profile black --line-length 79 src tests

upgrade-reqs:
    @{{repo}}/.venv/bin/pip-compile --upgrade --allow-unsafe --generate-hashes --no-emit-index-url requirements.in
    @{{repo}}/.venv/bin/pip-compile --upgrade --allow-unsafe --generate-hashes --no-emit-index-url requirements-dev.in

clean-state:
    @rm -rf "$HOME/.local/state/dotfiles"
