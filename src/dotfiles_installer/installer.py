"""Installation steps for the development environment."""

from __future__ import annotations

import hashlib
import logging
import os
import shutil
import tarfile
import tempfile
import time
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from lincl import CommandCallable, CommandNotFoundError

from dotfiles_installer.commands import CommandError
from dotfiles_installer.context import InstallContext

logger = logging.getLogger(__name__)

MISE_VERSION = "2026.7.13"
MISE_SHA256 = (
    "7e24785cd242e1b5b1704cdd8d877058a5dbb8eb871605858612676b640fdd7b"
)
MISE_URL = (
    "https://github.com/jdx/mise/releases/download/"
    f"v{MISE_VERSION}/install.sh"
)
BLESH_VERSION = "0.4.0-devel3"
BLESH_SHA256 = (
    "c8612ee612bc6b10dbfd6e85c6cbdfd7caf152a12d1f9de22ea0a9d735b3080c"
)
BLESH_URL = (
    "https://github.com/akinomyoga/ble.sh/releases/download/"
    f"v{BLESH_VERSION}/ble-{BLESH_VERSION}.tar.xz"
)

APT_PACKAGES = (
    "bash",
    "ca-certificates",
    "curl",
    "git",
    "tmux",
    "unzip",
    "zip",
    "build-essential",
    "cmake",
    "fonts-powerline",
    "ripgrep",
    "shellcheck",
    "shfmt",
    "fzf",
)
RPM_PACKAGES = (
    "bash",
    "ca-certificates",
    "git",
    "tmux",
    "unzip",
    "zip",
    "gcc",
    "gcc-c++",
    "make",
    "cmake",
)


@dataclass(frozen=True)
class GitSource:
    """An immutable Git source selection."""

    repository: str
    reference: str
    commit: str

    @property
    def name(self) -> str:
        """Return the repository basename without its Git suffix."""
        return self.repository.rsplit("/", 1)[-1].removesuffix(".git")


# renovate: datasource=git-refs packageName=https://github.com/amix/vimrc currentValue=master  # noqa: E501
VIM_RUNTIME = GitSource(
    "https://github.com/amix/vimrc.git",
    "master",
    "46294d589d15d2e7308cf76c58f2df49bbec31e8",
)
VIM_PLUGINS = (
    # renovate: datasource=git-refs packageName=https://github.com/mattn/emmet-vim currentValue=master  # noqa: E501
    GitSource(
        "https://github.com/mattn/emmet-vim.git",
        "master",
        "92ef2f74f4093edc99db5e9e4cf7e40116a85bd6",
    ),
    # renovate: datasource=github-tags depName=preservim/tagbar versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/preservim/tagbar.git",
        "v3.1.1",
        "6c3e15ea4a1ef9619c248c2b1eced56a47b61a9e",
    ),
    # renovate: datasource=github-tags depName=preservim/nerdtree versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/preservim/nerdtree.git",
        "7.1.3",
        "9b465acb2745beb988eff3c1e4aa75f349738230",
    ),
    # renovate: datasource=github-tags depName=preservim/nerdcommenter versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/preservim/nerdcommenter.git",
        "2.7.0",
        "f575c18d05bb237ac6c62d972f10784b34be9bbe",
    ),
    # renovate: datasource=github-tags depName=vim-airline/vim-airline versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/vim-airline/vim-airline.git",
        "v0.12",
        "1586662296c9dc946083e17cb6a4ef0b3e7c0d68",
    ),
    # renovate: datasource=git-refs packageName=https://github.com/vim-airline/vim-airline-themes currentValue=master  # noqa: E501
    GitSource(
        "https://github.com/vim-airline/vim-airline-themes.git",
        "master",
        "77aab8c6cf7179ddb8a05741da7e358a86b2c3ab",
    ),
    # renovate: datasource=github-tags depName=morhetz/gruvbox versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/morhetz/gruvbox.git",
        "v2.0.0",
        "7fde9c10ceff684529c1646bf759af3a25bb576c",
    ),
    # renovate: datasource=github-tags depName=psf/black versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/psf/black.git",
        "26.5.1",
        "87928e6d6761a4a6d22250e1fee5601b3998086e",
    ),
    # renovate: datasource=github-tags depName=vim-syntastic/syntastic versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/vim-syntastic/syntastic.git",
        "3.10.0",
        "767b4f3b3ed9567c13568b9eff1b302638abedd9",
    ),
    # renovate: datasource=github-tags depName=tpope/vim-fugitive versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/tpope/vim-fugitive.git",
        "v3.7",
        "96c1009fcf8ce60161cc938d149dd5a66d570756",
    ),
    # renovate: datasource=github-tags depName=xolox/vim-misc versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/xolox/vim-misc.git",
        "1.17.6",
        "3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b",
    ),
    # renovate: datasource=github-tags depName=xolox/vim-session versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/xolox/vim-session.git",
        "2.13.1",
        "9e9a6088f0554f6940c19889d0b2a8f39d13f2bb",
    ),
    # renovate: datasource=github-tags depName=phpactor/phpactor versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/phpactor/phpactor.git",
        "2025.12.21.1",
        "dbad0a9aad7be178b914f430b573d970f271b455",
    ),
    # renovate: datasource=github-tags depName=tpope/vim-commentary versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/tpope/vim-commentary.git",
        "v1.3",
        "34976d96b61d49cafce624cdd947317111c43bd8",
    ),
    # renovate: datasource=github-tags depName=tpope/vim-surround versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/tpope/vim-surround.git",
        "v2.2",
        "aeb933272e72617f7c4d35e1f003be16836b948d",
    ),
    # renovate: datasource=github-tags depName=tpope/vim-repeat versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/tpope/vim-repeat.git",
        "v1.2",
        "8106e142dfdc278ff3eaaadd7b362ad7949d4357",
    ),
    # renovate: datasource=github-tags depName=github/copilot.vim versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/github/copilot.vim.git",
        "v1.59.0",
        "a12fd5672110c8aa7e3c8419e28c96943ca179",
    ),
    # renovate: datasource=github-tags depName=ryanoasis/vim-devicons versioning=semver-coerced  # noqa: E501
    GitSource(
        "https://github.com/ryanoasis/vim-devicons.git",
        "v0.11.0",
        "4db2a6ddaf66afa16105b7d2a13f81a9bb5ff9fc",
    ),
    # renovate: datasource=git-refs packageName=https://github.com/vwxyutarooo/nerdtree-devicons-syntax currentValue=master  # noqa: E501
    GitSource(
        "https://github.com/vwxyutarooo/nerdtree-devicons-syntax.git",
        "master",
        "1beb45a702d707ca258e1af181e5d1ec836392f2",
    ),
)


def retry(operation: Callable[[], None], description: str) -> None:
    """Retry a fallible operation three times with bounded backoff."""
    for attempt in range(1, 4):
        try:
            operation()
            return
        except (CommandError, OSError) as error:
            if attempt == 3:
                raise RuntimeError(
                    f"failed after three attempts: {description}"
                ) from error
            delay = 2**attempt
            logger.warning(
                "%s failed; retrying in %s seconds", description, delay
            )
            time.sleep(delay)


def download(url: str, destination: Path, expected_sha256: str) -> None:
    """Download an HTTPS artifact and enforce its pinned digest."""
    if not url.startswith("https://"):
        raise ValueError("downloads require HTTPS")
    with urllib.request.urlopen(url, timeout=60) as response:
        with destination.open("wb") as output_file:
            shutil.copyfileobj(response, output_file)
    actual_sha256 = hashlib.sha256(destination.read_bytes()).hexdigest()
    if actual_sha256 != expected_sha256:
        destination.unlink(missing_ok=True)
        raise ValueError(f"checksum verification failed for {url}")


def extract_tar_archive(archive: Path, destination: Path) -> None:
    """Extract regular archive content without allowing path traversal."""
    destination_root = destination.resolve()
    with tarfile.open(archive, "r:xz") as source_archive:
        for member in source_archive.getmembers():
            extracted_path = (destination / member.name).resolve()
            if (
                extracted_path != destination_root
                and destination_root not in extracted_path.parents
            ):
                raise ValueError(f"unsafe archive member: {member.name}")
            if member.issym() or member.islnk():
                raise ValueError(f"archive link is not allowed: {member.name}")
        source_archive.extractall(destination)


def create_workspace(context: InstallContext) -> None:
    """Create the opinionated workspace hierarchy."""
    for relative_path in ("src", "src/data", "src/tools", "src/github.com"):
        context.create_directory(context.home / relative_path)


def detect_os() -> str:
    """Read the operating-system identifier without executing shell code."""
    release_file = Path("/etc/os-release")
    if not release_file.exists():
        return "unknown"
    for line in release_file.read_text(encoding="utf-8").splitlines():
        if line.startswith("ID="):
            return line.partition("=")[2].strip().strip('"')
    return "unknown"


def install_system_packages(context: InstallContext) -> None:
    """Install optional packages when non-interactive sudo is available."""
    try:
        from lincl import sudo
    except CommandNotFoundError:
        logger.warning("sudo unavailable; skipping optional system packages")
        return

    try:
        context.runner.run(sudo, ("-n", "true"))
    except CommandError:
        logger.warning(
            "passwordless sudo unavailable; skipping system packages"
        )
        return

    os_id = detect_os()
    if os_id in {"debian", "ubuntu", "raspbian", "raspberrypi"}:
        retry(
            lambda: context.runner.run(sudo, ("apt-get", "update")),
            "apt update",
        )
        retry(
            lambda: context.runner.run(
                sudo, ("apt-get", "install", "--yes", *APT_PACKAGES)
            ),
            "apt package installation",
        )
        install_first_editor(
            context,
            sudo,
            "apt-get",
            ("vim", "vim-nox", "neovim"),
        )
    elif os_id in {"fedora", "rhel", "centos"}:
        manager = rpm_package_manager()
        if manager is None:
            logger.warning("dnf and yum unavailable; skipping system packages")
            return
        retry(
            lambda: context.runner.run(
                sudo, (manager, "install", "-y", *RPM_PACKAGES)
            ),
            f"{manager} package installation",
        )
        install_first_editor(
            context,
            sudo,
            manager,
            ("vim-enhanced", "vim", "neovim"),
        )
    else:
        logger.warning("unsupported OS %s; skipping system packages", os_id)


def rpm_package_manager() -> str | None:
    """Return the preferred available RPM package manager."""
    try:
        from lincl import dnf

        return Path(dnf.executable).name
    except CommandNotFoundError:
        try:
            from lincl import yum

            return Path(yum.executable).name
        except CommandNotFoundError:
            return None


def install_first_editor(
    context: InstallContext,
    sudo_command: CommandCallable[str],
    manager: str,
    packages: tuple[str, ...],
) -> None:
    """Install the first available editor package from an ordered list."""
    for package in packages:
        arguments = (manager, "install", "--yes", package)
        if manager != "apt-get":
            arguments = (manager, "install", "-y", package)
        try:
            context.runner.run(sudo_command, arguments)
            return
        except CommandError:
            logger.warning("editor package unavailable: %s", package)
    logger.warning("no editor package fallback could be installed")


def install_mise(context: InstallContext) -> None:
    """Install the pinned mise release for the current user."""
    target = context.home / ".local/bin/mise"
    if target.is_file() and os.access(target, os.X_OK):
        logger.info("mise already installed")
        return
    if context.dry_run:
        logger.info("dry-run: install mise %s to %s", MISE_VERSION, target)
        return
    from lincl import sh

    with tempfile.TemporaryDirectory(prefix="dotfiles-mise-") as temporary:
        installer = Path(temporary) / "install.sh"
        retry(
            lambda: download(MISE_URL, installer, MISE_SHA256),
            "mise download",
        )
        target.parent.mkdir(parents=True, exist_ok=True)
        context.runner.run(
            sh,
            (installer,),
            environment={
                "MISE_VERSION": f"v{MISE_VERSION}",
                "MISE_INSTALL_PATH": str(target),
            },
        )
    if not target.is_file():
        raise RuntimeError("mise installer completed without creating mise")


def install_tools(context: InstallContext) -> None:
    """Install the versions declared by the repository mise configuration."""
    mise = context.home / ".local/bin/mise"
    if context.dry_run and not mise.exists():
        logger.info("dry-run: mise trust and install")
        return
    if not mise.exists():
        raise FileNotFoundError("mise is required before installing tools")
    from lincl import mise as mise_command

    retry(
        lambda: context.runner.run(mise_command, ("trust", context.repo_root)),
        "mise trust",
    )
    retry(
        lambda: context.runner.run(mise_command, ("install",)),
        "mise install",
    )


def configure_git(context: InstallContext) -> None:
    """Configure the default Git editor when Git is installed."""
    try:
        from lincl import git
    except CommandNotFoundError:
        logger.warning("git unavailable; skipping Git configuration")
        return

    context.runner.run(git, ("config", "--global", "core.editor", "vim"))


def install_bash(context: InstallContext) -> None:
    """Install Oh My Bash and persistent mise activation."""
    bashrc = context.home / ".bashrc.omb"
    oh_my_bash = context.home / ".oh-my-bash"
    git_command: CommandCallable[str] | None = None
    if not bashrc.exists():
        if context.dry_run:
            logger.info("dry-run: install Oh My Bash")
        else:
            try:
                from lincl import git as git_command
            except CommandNotFoundError:
                logger.warning("git unavailable; skipping Oh My Bash")

        if git_command is not None:
            if oh_my_bash.exists():
                context.backup(oh_my_bash)
            context.runner.run(
                git_command,
                (
                    "clone",
                    "--depth=1",
                    "https://github.com/ohmybash/oh-my-bash.git",
                    oh_my_bash,
                ),
            )
            template = oh_my_bash / "templates/bashrc.osh-template"
            content = template.read_text(encoding="utf-8")
            content = content.replace(
                'OSH_THEME="font"', "OSH_THEME='agnoster'"
            )
            bashrc.write_text(content, encoding="utf-8")
    activation = (
        'if [ -x "$HOME/.local/bin/mise" ]; then '
        'eval "$("$HOME/.local/bin/mise" activate bash)"; fi'
    )
    for profile in (context.home / ".profile", context.home / ".bash_profile"):
        context.append_once(profile, "# dotfiles mise activation", activation)


def link_dotfiles(context: InstallContext) -> None:
    """Link each managed dotfile into the current home directory."""
    mappings = (
        ("dotfiles/bash/.bashrc", ".bashrc"),
        ("dotfiles/bash/.bash_aliases", ".bash_aliases"),
        ("dotfiles/bash/.blerc", ".blerc"),
        ("dotfiles/tmux/.tmux.conf", ".tmux.conf"),
        ("dotfiles/vim/.vimrc", ".vimrc"),
        ("dotfiles/nvim/.config/nvim/init.vim", ".config/nvim/init.vim"),
    )
    for source, target in mappings:
        context.link(context.repo_root / source, context.home / target)


def install_fzf(context: InstallContext) -> None:
    """Install fzf under HOME when no executable is already available."""
    try:
        from lincl import fzf

        logger.debug("fzf already available at %s", fzf.executable)
        return
    except CommandNotFoundError:
        pass
    from lincl import env

    try:
        from lincl import git
    except CommandNotFoundError:
        logger.warning("git unavailable; skipping fzf fallback")
        return

    destination = context.home / ".fzf"
    if not (destination / ".git").exists():
        if context.dry_run:
            logger.info("dry-run: clone fzf to %s", destination)
            return
        context.runner.run(
            git,
            (
                "clone",
                "--depth",
                "1",
                "https://github.com/junegunn/fzf.git",
                destination,
            ),
        )
    installer = destination / "install"
    if installer.exists():
        context.runner.run(
            env,
            (
                installer,
                "--key-bindings",
                "--completion",
                "--no-update-rc",
            ),
        )


def install_blesh(context: InstallContext) -> None:
    """Install the pinned, checksummed ble.sh archive."""
    destination = context.home / ".local/share/blesh"
    version_file = destination / ".dotfiles-version"
    if (
        (destination / "ble.sh").exists()
        and version_file.exists()
        and version_file.read_text(encoding="utf-8").strip() == BLESH_VERSION
    ):
        return
    if context.dry_run:
        logger.info("dry-run: install ble.sh %s", BLESH_VERSION)
        return
    with tempfile.TemporaryDirectory(prefix="dotfiles-blesh-") as temporary:
        temporary_path = Path(temporary)
        archive = temporary_path / "ble.tar.xz"
        retry(
            lambda: download(BLESH_URL, archive, BLESH_SHA256),
            "ble.sh download",
        )
        extract_tar_archive(archive, temporary_path)
        extracted = temporary_path / f"ble-{BLESH_VERSION}"
        if not (extracted / "ble.sh").is_file():
            raise RuntimeError("ble.sh archive has an unexpected layout")
        (extracted / ".dotfiles-version").write_text(
            f"{BLESH_VERSION}\n", encoding="utf-8"
        )
        context.backup(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(extracted, destination)


def checkout_source(
    context: InstallContext,
    git_command: CommandCallable[str] | None,
    source: GitSource,
    destination: Path,
) -> None:
    """Converge a Git checkout on its pinned commit."""
    if context.dry_run:
        logger.info("dry-run: checkout %s at %s", source.name, source.commit)
        return
    if git_command is None:
        raise RuntimeError("git is required for a non-preview checkout")

    if (destination / ".git").exists():
        try:
            context.runner.run(
                git_command,
                (
                    "-C",
                    destination,
                    "fetch",
                    "--depth",
                    "1",
                    "origin",
                    source.commit,
                ),
            )
        except CommandError:
            context.runner.run(
                git_command,
                ("-C", destination, "fetch", "origin", source.reference),
            )
    else:
        context.runner.run(
            git_command,
            ("clone", "--no-checkout", source.repository, destination),
        )
        context.runner.run(
            git_command,
            (
                "-C",
                destination,
                "fetch",
                "--depth",
                "1",
                "origin",
                source.commit,
            ),
        )
    context.runner.run(
        git_command,
        ("-C", destination, "checkout", "--detach", source.commit),
    )
    context.runner.run(
        git_command,
        ("-C", destination, "submodule", "update", "--init", "--recursive"),
    )


def install_vim(context: InstallContext) -> None:
    """Install the pinned Vim runtime and plugins."""
    git_command: CommandCallable[str] | None = None
    if not context.dry_run:
        try:
            from lincl import git as git_command
        except CommandNotFoundError as error:
            raise RuntimeError(
                "git is required to install the Vim runtime"
            ) from error
    runtime = Path(
        os.environ.get("VIM_RUNTIME_DIR", context.home / "opt/vimrc.runtime")
    )
    checkout_source(context, git_command, VIM_RUNTIME, runtime)
    plugins = runtime / "my_plugins"
    context.create_directory(plugins)
    for source in VIM_PLUGINS:
        try:
            checkout_source(
                context,
                git_command,
                source,
                plugins / source.name,
            )
        except CommandError:
            logger.warning(
                "failed to install optional Vim plugin %s", source.name
            )
    context.link(
        context.repo_root / "dotfiles/vim/.config/dotfiles/vim/my_configs.vim",
        runtime / "my_configs.vim",
    )


def install(context: InstallContext) -> None:
    """Run the complete, ordered current-user installation."""
    create_workspace(context)
    try:
        install_system_packages(context)
    except RuntimeError:
        logger.warning("system package installation failed; continuing")
    install_mise(context)
    install_tools(context)
    configure_git(context)
    install_bash(context)
    link_dotfiles(context)
    try:
        install_fzf(context)
        install_blesh(context)
    except (CommandError, RuntimeError, OSError):
        logger.warning("optional Bash enhancement failed", exc_info=True)
    try:
        install_vim(context)
    except (CommandError, RuntimeError, OSError):
        logger.warning("Vim runtime installation failed", exc_info=True)
