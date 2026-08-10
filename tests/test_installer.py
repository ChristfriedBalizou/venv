"""Unit and end-to-end preview tests for installer behavior."""

from __future__ import annotations

import os
import stat
import subprocess
import sys
import tarfile
from io import BytesIO
from pathlib import Path

import pytest

from dotfiles_installer.context import InstallContext
from dotfiles_installer.installer import (
    configure_git,
    detect_os,
    download,
    extract_tar_archive,
    install_fzf,
    install_system_packages,
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


def test_optional_git_is_resolved_by_lincl(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    caplog: pytest.LogCaptureFixture,
) -> None:
    home = tmp_path / "home"
    home.mkdir()
    context = InstallContext(
        tmp_path,
        home,
        tmp_path / "state",
        False,
    )
    monkeypatch.setenv("PATH", str(tmp_path / "empty-path"))

    configure_git(context)

    assert "git unavailable" in caplog.text


def test_fzf_clone_uses_public_lincl_command_chaining(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    home = tmp_path / "home"
    home.mkdir()
    executable_directory = tmp_path / "bin"
    executable_directory.mkdir()
    arguments_file = tmp_path / "git-arguments"
    git = executable_directory / "git"
    git.write_text(
        "#!/bin/sh\n"
        'printf \'%s\\n\' "$@" > "$GIT_ARGUMENTS_FILE"\n'
        '/bin/mkdir -p "$4/.git"\n',
        encoding="utf-8",
    )
    git.chmod(git.stat().st_mode | stat.S_IXUSR)
    (executable_directory / "env").symlink_to("/usr/bin/env")
    monkeypatch.setenv("PATH", str(executable_directory))
    monkeypatch.setenv("GIT_ARGUMENTS_FILE", str(arguments_file))
    context = InstallContext(tmp_path, home, tmp_path / "state", False)

    install_fzf(context)

    assert arguments_file.read_text(encoding="utf-8").splitlines() == [
        "clone",
        "--depth=1",
        "https://github.com/junegunn/fzf.git",
        str(home / ".fzf"),
    ]


def test_apt_install_uses_public_lincl_command_chaining(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    executable_directory = tmp_path / "bin"
    executable_directory.mkdir()
    arguments_file = tmp_path / "sudo-arguments"
    sudo = executable_directory / "sudo"
    sudo.write_text(
        "#!/bin/sh\n"
        'printf \'%s|\' "$@" >> "$SUDO_ARGUMENTS_FILE"\n'
        "printf '\\n' >> \"$SUDO_ARGUMENTS_FILE\"\n",
        encoding="utf-8",
    )
    sudo.chmod(sudo.stat().st_mode | stat.S_IXUSR)
    monkeypatch.setenv("PATH", str(executable_directory))
    monkeypatch.setenv("SUDO_ARGUMENTS_FILE", str(arguments_file))
    monkeypatch.setattr(
        "dotfiles_installer.installer.detect_os",
        lambda: "debian",
    )
    context = InstallContext(tmp_path, tmp_path, tmp_path / "state", False)

    install_system_packages(context)

    calls = arguments_file.read_text(encoding="utf-8").splitlines()
    assert calls[0] == "-n|true|"
    assert calls[1] == "apt-get|update|"
    assert calls[2].startswith("apt-get|install|--yes|bash|")
    assert calls[3] == "apt-get|install|--yes|vim|"


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
