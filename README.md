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

Preview changes without writing files:

```bash
just dry-run
```

## Commands

```bash
just install      # full setup
just dry-run      # preview actions
just check        # shell syntax and shellcheck when available
just fmt          # format shell scripts when shfmt is available
just clean-state  # remove dotfiles installer logs and backups
```

## Dependency Updates

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
scripts/           # installer steps and shared safety helpers
```
