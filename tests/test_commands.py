"""Regression tests for the lincl execution boundary."""

from __future__ import annotations

import logging
import os
import stat
from pathlib import Path

import pytest
from lincl import (
    CommandCallable,
    CommandExecutionError,
    CommandResult,
    CommandTimeoutError,
)

from dotfiles_installer.commands import CommandRunner, RedactedCommandError


def executable_fixture(
    directory: Path,
    body: str,
    monkeypatch: pytest.MonkeyPatch,
) -> CommandCallable[str]:
    """Create a controlled executable for command-boundary tests."""
    executable = directory / "fixture_command"
    executable.write_text(f"#!/bin/sh\n{body}\n", encoding="utf-8")
    executable.chmod(executable.stat().st_mode | stat.S_IXUSR)
    monkeypatch.setenv("PATH", f"{directory}:{os.environ['PATH']}")
    from lincl import fixture_command

    return fixture_command


def test_arguments_are_not_evaluated_by_a_shell(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    marker = tmp_path / "injected"
    command = executable_fixture(tmp_path, 'printf "%s" "$1"', monkeypatch)
    argument = f"$(touch {marker})"

    result = CommandRunner().run(command, (argument,))

    assert isinstance(result, CommandResult)
    assert result.args == (command.executable, argument)
    assert result.stdout == argument
    assert result.value == argument
    assert not marker.exists()


def test_failure_redacts_selected_arguments(
    tmp_path: Path,
    caplog: pytest.LogCaptureFixture,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    command = executable_fixture(tmp_path, "exit 2", monkeypatch)
    secret = "token-that-must-not-leak"

    with (
        caplog.at_level(logging.INFO),
        pytest.raises(RedactedCommandError) as raised,
    ):
        CommandRunner().run(
            command,
            ("--token", secret),
            redacted_arguments=frozenset({1}),
        )

    assert secret not in str(raised.value)
    assert secret not in caplog.text
    assert "<redacted>" in caplog.text
    assert raised.value.__cause__ is not None


def test_failure_preserves_lincl_error_metadata(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    command = executable_fixture(
        tmp_path, "printf failure >&2; exit 7", monkeypatch
    )

    with pytest.raises(CommandExecutionError) as raised:
        CommandRunner().run(command)

    assert raised.value.returncode == 7
    assert raised.value.stderr == "failure"
    assert raised.value.args_vector == (command.executable,)


def test_timeout_has_stable_error_shape(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    command = executable_fixture(tmp_path, "sleep 5", monkeypatch)

    with pytest.raises(CommandTimeoutError) as raised:
        CommandRunner().run(command, timeout=0.01)

    assert raised.value.timeout == 0.01
    assert raised.value.args_vector[0] == command.executable


def test_environment_is_explicit(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    command = executable_fixture(
        tmp_path,
        'printf "%s" "${CONTROLLED_VALUE-unset}"',
        monkeypatch,
    )

    result = CommandRunner().run(
        command, environment={"CONTROLLED_VALUE": "expected"}
    )

    assert result.stdout == "expected"
