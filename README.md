# Dotfiles

Dotfiles is my current-user development environment bootstrap. It configures bash,
tmux, Vim/Neovim, workspace directories, and user-space development tools.

The setup is intentionally opinionated: there are no user-selection flags and no
Ansible. Running the installer applies the full environment to the connected
user.

## Install

```bash
./bootstrap.sh
```

After the first install, use:

```bash
just install
```

If `just` is not available in the current shell yet:

```bash
mise run install
```

## What It Does

- Creates workspace directories:
  - `~/src`
  - `~/src/data`
  - `~/src/tools`
  - `~/src/github.com`
- Installs optional system packages when passwordless `sudo` is available.
- Installs `mise` for the current user when missing.
- Installs development tools from `mise.toml`.
- Installs Oh My Bash.
- Installs `ble.sh` for history suggestions, syntax highlighting, and completion menus.
- Links bash, tmux, and Neovim dotfiles into `$HOME`.
- Installs `fzf` with a user-space fallback.
- Installs the Vim runtime under `~/opt/vimrc.runtime`.

## Safety

The installer is designed to be rerunnable.

- Existing files are backed up before replacement.
- Network operations retry with backoff.
- Optional system package failures warn and continue.
- Logs are written to `~/.local/state/dotfiles/install.log`.
- Backups are written to `~/.local/state/dotfiles/backups/`.
- Desktop notifications are sent when `notify-send` or `terminal-notifier` is
  available.

## Continuous Integration

The blocking test workflow validates Python and bootstrap style, then runs a complete
fresh install in clean Debian 12, Debian 13, Ubuntu 22.04, Ubuntu 24.04, and CentOS
Stream 9 containers. Every matrix entry verifies installed features, reruns the
installer through `just install`, and checks `just dry-run`.

Configure the repository rule for `main` to require the stable `CI Required`
status check. A failure in lint or any operating-system install then blocks merges.

Preview changes without writing files:

```bash
just dry-run
```

## Commands

```bash
just install      # full setup
just dry-run      # preview actions
just check        # run pytest and every pre-commit hook
just fmt          # format Python sources and tests
just clean-state  # remove dotfiles installer logs and backups
```

## Dependency Updates

Python dependencies are declared in `requirements.in` and
`requirements-dev.in`, then hash-locked with `pip-tools`. The installer uses
`lincl` 3.0.0 is pinned to its immutable upstream commit. Install a development
environment with:

```bash
python3 -m venv .venv
.venv/bin/pip install pip-tools
.venv/bin/pip-sync requirements.txt requirements-dev.txt
.venv/bin/pip install --no-deps -e .
.venv/bin/pre-commit install --install-hooks
```

Tool versions are pinned in `mise.toml` and resolved in `mise.lock`.
Mise updates are handled manually because Renovate's mise manager is disabled.
Renovate is configured in `.renovaterc.json5` and extends the shared
`github>christfriedbalizou/renovate` preset.

Merged Renovate updates on `main` are tagged automatically by
`.github/workflows/tag.yaml`.

- `type/major` Renovate updates create the next `vMAJOR.0.0` tag.
- `type/minor` Renovate updates create the next `vMAJOR.MINOR.0` tag.
- `type/patch`, digest, pin, and lock-file updates create the next patch tag.

## Layout

```text
bootstrap.sh       # fresh-machine entry point
justfile           # local command runner
mise.toml          # tool versions and mise tasks
mise.lock          # resolved mise tool artifacts and checksums
dotfiles/          # files linked into $HOME
src/dotfiles_installer/ # typed Python installer using lincl commands
requirements*.in  # direct runtime and development dependency inputs
requirements*.txt # hash-pinned dependency lockfiles
```
