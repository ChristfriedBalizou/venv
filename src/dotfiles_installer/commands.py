"""Safe command execution through lincl."""

from __future__ import annotations

import logging
import os
import shlex
from pathlib import Path
from typing import Mapping, Sequence

from lincl import (
    CommandCallable,
    CommandError,
    CommandResult,
    ExecutionOptions,
)

logger = logging.getLogger(__name__)


class RedactedCommandError(CommandError):
    """Report a command failure without exposing selected arguments."""


class CommandRunner:
    """Execute argument arrays without shell parsing, using lincl."""

    def __init__(self, dry_run: bool = False) -> None:
        self.dry_run = dry_run

    def run(
        self,
        command: CommandCallable[str],
        arguments: Sequence[str | Path] = (),
        *,
        environment: Mapping[str, str] | None = None,
        redacted_arguments: frozenset[int] = frozenset(),
        timeout: float = 300,
    ) -> CommandResult[str]:
        """Run one command with literal arguments and captured output."""
        executable = command.executable
        command_arguments = [str(argument) for argument in arguments]
        display_arguments = [
            "<redacted>" if index in redacted_arguments else argument
            for index, argument in enumerate(command_arguments)
        ]
        logger.info(
            "run: %s",
            shlex.join([executable, *display_arguments]),
        )
        if self.dry_run:
            return CommandResult(
                args=(executable, *command_arguments),
                returncode=0,
                stdout="",
                stderr="",
                value="",
            )

        try:
            return command.run(
                *command_arguments,
                execution=ExecutionOptions(
                    timeout=timeout,
                    env=(
                        {**os.environ, **environment}
                        if environment is not None
                        else None
                    ),
                ),
            )
        except CommandError as error:
            if not redacted_arguments:
                raise
            safe_command = shlex.join([executable, *display_arguments])
            raise RedactedCommandError(
                f"command failed: {safe_command}"
            ) from error
