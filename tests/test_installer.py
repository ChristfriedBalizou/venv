"""Unit and end-to-end preview tests for installer behavior."""

from __future__ import annotations

import os
import subprocess
import sys
import tarfile
from io import BytesIO
from pathlib import Path

import pytest

from dotfiles_installer.installer import (
    detect_os,
    download,
    extract_tar_archive,
)


def test_download_rejects_non_https(tmp_path: Path) -> None:
    destination = tmp_path / "artifact"

    try:
        download("http://example.invalid/artifact", destination, "unused")
    except ValueError as error:
        assert str(error) == "downloads require HTTPS"
    else:
        raise AssertionError("non-HTTPS URL was accepted")


def test_detect_os_returns_identifier() -> None:
    assert detect_os()


def test_archive_path_traversal_is_rejected(tmp_path: Path) -> None:
    archive = tmp_path / "malicious.tar.xz"
    with tarfile.open(archive, "w:xz") as output_archive:
        member = tarfile.TarInfo("../escaped")
        member.size = 7
        output_archive.addfile(member, BytesIO(b"escaped"))

    with pytest.raises(ValueError, match="unsafe archive member"):
        extract_tar_archive(archive, tmp_path / "extract")

    assert not (tmp_path / "escaped").exists()


def test_full_dry_run_is_non_mutating(tmp_path: Path) -> None:
    home = tmp_path / "home"
    home.mkdir()
    repo_root = Path(__file__).resolve().parents[1]
    environment = os.environ.copy()
    environment.update(
        {
            "DOTFILES_DRY_RUN": "1",
            "DOTFILES_REPO_ROOT": str(repo_root),
            "DOTFILES_STATE_DIR": str(tmp_path / "state"),
            "HOME": str(home),
            "PYTHONPATH": str(repo_root / "src"),
        }
    )

    result = subprocess.run(
        [sys.executable, "-m", "dotfiles_installer.cli"],
        capture_output=True,
        check=False,
        env=environment,
        text=True,
        timeout=30,
    )

    assert result.returncode == 0, result.stderr
    assert not (home / "src").exists()
    assert not (home / ".bashrc").exists()
