"""This file is an "apt-get" and "dpkg" compliance
installer.

This following script are aim to install and verify integrity
of a complete package installation.

The workflow is at follow:
    - Search (Look for the package to install)
    - Dependencies (Dry run dependencies follow by installation)
    - Package (Dry run install follow by installation)
    - Checksums (Verify integrity)
    - Status (Check installation status)
"""
from typing import List, Union, Dict
from subprocess import CalledProcessError, check_output, PIPE


REQUIRED_PACKAGES = ("debsums",)  # Main package to install and check
COMMANDES = (
    "apt-cache search {name}",
    "apt-get --yes --simulate build-dep {name}",
    "apt-get --yes build-dep {name}",
    "apt-get --yes --simulate install {name}",
    "apt-get --yes install {name}",
    "debsums {name}",
    "dpkg-query -W -f='{fmt}' {name}",
)  # commands to perform on each package


class PackageQuery: # pylint: disable=too-few-public-methods
    """A class use to formulate an installation
    request
    """
    name: str
    fmt: str = "${Status}\n"

    @property
    def as_dict(self) -> Dict:
        """return as dictionary
        """
        return {
            "name": self.name,
            "fmt": self.fmt,
        }


class InstallationErrors:
    """This class store a collection of installation
    errors accuring installing multiple packages
    """
    def __init__(self):
        self.errors: List[CalledProcessError] = []

    def push(self, error: CalledProcessError) -> None:
        """Append to error list if error is not None

        Arguments:
            error: An error to add

        Return:
            void
        """
        if error:
            self.errors.append(error)

    def __len__(self) -> int:
        """Return the length of self.errors
        """
        return len(self.errors)


def install(query: PackageQuery) -> Union[CalledProcessError, None]:
    """This function trigger a suite case of installation
    process

    Argument:
        query: information for commands

    Return:
        CalledProcessError if an error occure otherwise None
    """

    for command in COMMANDES:
        try:
            check_output(
                command.format(**query.as_dict).split(),
                universal_newlines=True,
                stderr=PIPE
            )
        except CalledProcessError as error:
            # YOLO I want to return instead of raise
            # to be able to use the instance after
            return error

    return None


def install_packages(packages: List[str]) -> InstallationErrors:
    """The installation will be triggered by the following
    function and will store error if they ever occure

    Arguments:
        packages: A list of Debian based package

    Return:
        An InstallationErrors instance
    """
    for package in REQUIRED_PACKAGES:
        error = install(PackageQuery(name=package))

        if error:
            # Those package are required to continue
            # in case an error occure while installing
            # we raise the error and stop going futher
            raise error # pylint: disable=raising-bad-type

    sentinel = InstallationErrors()

    for package in packages:
        error = install(PackageQuery(name=package))
        sentinel.push(error)

    return sentinel