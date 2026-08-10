"""Safe command execution through lincl."""

from __future__ import annotations

import logging
import os
import shlex
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping, Sequence

from lincl import CommandCallable, ExecutionOptions
from lincl.exceptions import CommandError as LinclCommandError

logger = logging.getLogger(__name__)


class CommandError(RuntimeError):
    """Report a failed external command without exposing secret values."""


@dataclass(frozen=True)
class CommandResult:
    """Captured output from a successfully completed command."""

    stdout: str
    stderr: str


class CommandRunner:
    """Execute argument arrays without shell parsing, using lincl."""

    def __init__(self, dry_run: bool = False) -> None:
        self.dry_run = dry_run

    def available(self, executable: str) -> bool:
        """Return whether an executable is discoverable through PATH."""
        return shutil.which(executable) is not None

    def run(
        self,
        command: CommandCallable[str],
        arguments: Sequence[str | Path] = (),
        *,
        environment: Mapping[str, str] | None = None,
        redacted_arguments: frozenset[int] = frozenset(),
        timeout: float = 300,
    ) -> CommandResult:
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
            return CommandResult("", "")

        try:
            result = command.run(
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
        except LinclCommandError as error:
            safe_command = shlex.join([executable, *display_arguments])
            raise CommandError(f"command failed: {safe_command}") from error
        return CommandResult(result.stdout, result.stderr)
