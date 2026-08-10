"""Command-line entry point for the dotfiles installer."""

from __future__ import annotations

import logging

from dotfiles_installer.context import InstallContext, configure_logging
from dotfiles_installer.installer import install

logger = logging.getLogger(__name__)


def main() -> int:
    context = InstallContext.from_environment()
    configure_logging(context.state_dir)
    logger.info("starting current-user setup in %s", context.repo_root)
    try:
        install(context)
    except (OSError, RuntimeError, ValueError) as error:
        logger.error("dotfiles setup failed: %s", error)
        return 1
    logger.info("dotfiles setup complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
