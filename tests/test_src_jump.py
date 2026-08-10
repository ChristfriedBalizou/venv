"""Tests for directory selection and lincl output parsing."""

from __future__ import annotations

import os
import stat
from pathlib import Path

import pytest

from dotfiles_installer.src_jump import first_path, fzf_match


def test_first_path_parses_command_output() -> None:
    assert first_path("/first/path\n/second/path\n") == Path("/first/path")
    assert first_path("") is None


def test_fzf_uses_lincl_options_and_configured_parser(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    executable_directory = tmp_path / "bin"
    executable_directory.mkdir()
    executable = executable_directory / "fzf"
    executable.write_text(
        "#!/bin/sh\n"
        'test "$1" = "--filter=project" || exit 2\n'
        'test "$2" = "--select-1" || exit 3\n'
        'test "$3" = "--exit-0" || exit 4\n'
        "IFS= read -r first_candidate\n"
        "printf '%s\\n' \"$first_candidate\"\n",
        encoding="utf-8",
    )
    executable.chmod(executable.stat().st_mode | stat.S_IXUSR)
    monkeypatch.setenv("PATH", f"{executable_directory}:{os.environ['PATH']}")
    candidate = tmp_path / "project"

    assert fzf_match([candidate], "project") == candidate
