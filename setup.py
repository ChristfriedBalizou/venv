import os
import re
import codecs

from setuptools import setup, find_packages


CURRENT_DIRECTORY = os.path.realpath(os.path.dirname(__file__))

SETUP_REQUIRES = (
    "pytest-runner"
)

INSTALL_REQUIRES = (
    "wheel >= 0.34.2",
    "GitPython == 3.1.11",
    "black == 20.8b1",
    "click == 7.1.2",
)

TESTS_REQUIRES = (
    "pytest",
    "pytest-pep8",
    "pytest-flakes",
)

EXTRAS_REQUIRE = {
    "dev": TESTS_REQUIRES
}

ENTRY_POINTS = {
    "console_scripts": ["venv=venv.main:main"]
}


def read(*paths):
    """This function aim to read from special
    files with special formatting using python
    codecs library.
    """

    path = os.path.join(CURRENT_DIRECTORY, *paths)

    with codecs.open(path) as stream:
        return stream.read()


def find_version(*file_paths):
    """Retrieve the version from a given file
    """
    version_file = read(*file_paths)
    version_match = re.search(
        r"^__version__ = [\"']([^\"'']*)[\"']",
        version_file,
        re.M
    )

    if version_match:
        return version_match.group(1)

    raise RuntimeError("Unable to find version")


setup(
    name="venv",
    version=find_version("venv", "__init__.py"),
    description="Linux application environement setup",
    long_description=read("README.md"),
    entry_points=ENTRY_POINTS,
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Environment :: Console",
        "License :: OSI Approved :: GPL License",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.7",
    ],
    keywords="env venv environement vimrc bashrc",
    author="Christfried BALIZOU",
    author_email="christfriedbalizou@gmail.com",
    license="GPL",
    packages=find_packages(),
    setup_requires=SETUP_REQUIRES,
    install_requires=INSTALL_REQUIRES,
    tests_require=TESTS_REQUIRES,
    extras_require=EXTRAS_REQUIRE,
    include_package_data=True,
    python_requires=">=3.6"
)
