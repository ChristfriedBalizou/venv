"""Tests for deterministic filesystem convergence."""

from pathlib import Path

import pytest

from dotfiles_installer.commands import CommandRunner
from dotfiles_installer.context import InstallContext


def context_for(tmp_path: Path, dry_run: bool = False) -> InstallContext:
    """Build an isolated installer context."""
    home = tmp_path / "home"
    home.mkdir()
    repo = tmp_path / "repo"
    repo.mkdir()
    return InstallContext(
        repo,
        home,
        home / ".local/state/dotfiles",
        dry_run,
        CommandRunner(dry_run),
    )


def test_link_is_idempotent(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    source = context.repo_root / "source"
    source.write_text("managed", encoding="utf-8")
    target = context.home / ".managed"

    context.link(source, target)
    context.link(source, target)

    assert target.is_symlink()
    assert target.readlink() == source


def test_backup_rejects_paths_outside_home(tmp_path: Path) -> None:
    context = context_for(tmp_path)
    outside = tmp_path / "outside"
    outside.write_text("user-owned", encoding="utf-8")

    with pytest.raises(ValueError, match="outside HOME"):
        context.backup(outside)

    assert outside.read_text(encoding="utf-8") == "user-owned"


def test_dry_run_does_not_mutate_files(tmp_path: Path) -> None:
    context = context_for(tmp_path, dry_run=True)
    source = context.repo_root / "source"
    source.write_text("managed", encoding="utf-8")
    target = context.home / ".managed"
    target.write_text("user-owned", encoding="utf-8")

    context.link(source, target)

    assert not target.is_symlink()
    assert target.read_text(encoding="utf-8") == "user-owned"
