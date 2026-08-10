"""Installer state, logging, and safe filesystem operations."""

from __future__ import annotations

import logging
import os
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from dotfiles_installer.commands import CommandRunner

logger = logging.getLogger(__name__)


@dataclass
class InstallContext:
    """Paths and operations shared by every installation step."""

    repo_root: Path
    home: Path
    state_dir: Path
    dry_run: bool
    runner: CommandRunner

    @classmethod
    def from_environment(cls) -> "InstallContext":
        repo_root = Path(
            os.environ.get(
                "DOTFILES_REPO_ROOT",
                Path(__file__).resolve().parents[2],
            )
        ).resolve()
        home = Path.home()
        state_dir = Path(
            os.environ.get(
                "DOTFILES_STATE_DIR",
                home / ".local/state/dotfiles",
            )
        )
        dry_run = os.environ.get("DOTFILES_DRY_RUN", "0") == "1"
        return cls(
            repo_root,
            home,
            state_dir,
            dry_run,
            CommandRunner(dry_run),
        )

    @property
    def backup_dir(self) -> Path:
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
        return self.state_dir / "backups" / timestamp

    def create_directory(self, directory: Path) -> None:
        if self.dry_run:
            logger.info("dry-run: mkdir -p %s", directory)
            return
        directory.mkdir(parents=True, exist_ok=True)

    def backup(self, target: Path) -> None:
        if not target.exists() and not target.is_symlink():
            return
        try:
            relative_target = target.relative_to(self.home)
        except ValueError as error:
            raise ValueError(
                f"refusing to back up outside HOME: {target}"
            ) from error
        destination = self.backup_dir / relative_target
        if self.dry_run:
            logger.info("dry-run: backup %s -> %s", target, destination)
            return
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(target, destination)
        logger.info("backed up %s", target)

    def link(self, source: Path, target: Path) -> None:
        if not source.exists():
            raise FileNotFoundError(f"missing link source: {source}")
        if target.is_symlink() and target.readlink() == source:
            logger.info("already linked %s", target)
            return
        self.backup(target)
        if self.dry_run:
            logger.info("dry-run: link %s -> %s", target, source)
            return
        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(source)
        logger.info("linked %s", target)

    def append_once(self, path: Path, marker: str, content: str) -> None:
        if path.exists() and marker in path.read_text(encoding="utf-8"):
            logger.info("already configured %s", path)
            return
        if self.dry_run:
            logger.info("dry-run: append %s to %s", marker, path)
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as output_file:
            output_file.write(f"\n{marker}\n{content}\n")


def configure_logging(state_dir: Path) -> None:
    """Send progress to the terminal and a persistent installer log."""
    state_dir.mkdir(parents=True, exist_ok=True)
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    stream_handler = logging.StreamHandler(sys.stderr)
    stream_handler.setFormatter(logging.Formatter("%(levelname)s %(message)s"))
    file_handler = logging.FileHandler(state_dir / "install.log")
    file_handler.setFormatter(formatter)
    logging.basicConfig(
        level=logging.INFO,
        handlers=[stream_handler, file_handler],
        force=True,
    )
