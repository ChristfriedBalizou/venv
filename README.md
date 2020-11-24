# Venv

Venv is a personal Linux(Debian) based project created to setup my development environment and server workstation.
You are allowed to use to setup you environment.

## Getting started

To first use the application, install using:
```bash
pip git+https://github.com/ChristfriedBalizou/venv.git#egg=venv
```

After installation run `venv --help` to see the command line help.

## Development

The development environment aim to setup your `profile` and your development tool
in my case `vim`.

### Profile

The profile will setup and base bashrc file containing a numeros function
like `extract` to decompress any zip, gz, ... files or `swap` to swap two
file content and many other cool functions.

This part will create your working directories:
- ${HOME}/src
- ${HOME}/src/data
- ${HOME}/src/tools
- ${HOME}/src/github.com

Will install [fzf][1] for fuzzy search
Will create your .bashrc and .bash_aliases


### Vim

Vim is my base editor and development tool. It was important to add plugins and
tools to make it easy to code with.

The base vimrc configuration comes from [amix/vimrc][2] and updated by my own
plugings as [python-mode][3], [black][4] and ...


[1]: https://github.com/junegunn/fzf
[2]: https://github.com/amix/vimrc
[3]: https://github.com/python-mode/python-mode
[4]: https://github.com/psf/black
