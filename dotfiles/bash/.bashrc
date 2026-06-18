# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# Save and reload the history after each command finishes
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# color list
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
WHITE=$(tput setaf 7)
RESET=$(tput setaf 0)

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f "$HOME/.bash_aliases" ]; then
   . "$HOME/.bash_aliases"
fi

if [ -x "$HOME/.local/bin/mise" ]; then
    eval "$("$HOME/.local/bin/mise" activate bash)"
fi

FZF_BASE="$HOME/.fzf"
PATH=$FZF_BASE/bin:$PATH

if command -v fzf &> /dev/null
then
    if [ -f $FZF_BASE/shell/key-bindings.bash ]; then
        . $FZF_BASE/shell/key-bindings.bash
    fi
    export FZF_DEFAULT_OPTS='--height 40% --multi -i --layout=reverse --border'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load your custom basrch file
if [ -f $HOME/.my_bashrc ]; then
    . $HOME/.my_bashrc
fi

# Update Powerline fonts
# POWERLINES=$(fc-list | grep Powerline -c)
# POWERLINE_FONTS=$HOME/.fonts

# if [ -f $POWERLINE_FONTS ] && [ $POWERLINES -eq 0 ]; then
#    fc-cache -f "${POWERLINE_FONTS}"
# fi

# Oh My Bash configuration
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true

if [ -f $HOME/.bashrc.omb ]; then
    . $HOME/.bashrc.omb
fi
eval "$(mise activate bash)"

# Fuzzy-jump under $HOME/src.
# Examples: src, src g, src g h b, src v teleport
unalias src 2>/dev/null
function src {
    __src_match "$HOME/src" "$@"
}

__src_complete_child() {
    local base="$1"
    local query="$2"
    local child name clean
    local -a matches=()

    [ -d "$base" ] || return 1

    for child in "$base"/*; do
        [ -d "$child" ] || continue
        name="${child##*/}"
        clean="${name%.git}"

        if [[ "$name" == "$query" || "$clean" == "$query" ]]; then
            printf '%s\n' "$child"
            return 0
        fi

        if [[ "$name" == "$query"* || "$clean" == "$query"* ]]; then
            matches+=("$child")
        fi
    done

    if [ "${#matches[@]}" -eq 1 ]; then
        printf '%s\n' "${matches[0]}"
        return 0
    fi

    return 1
}

__src_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local base="$HOME/src"
    local word child name clean
    local -a candidates=()

    for word in "${COMP_WORDS[@]:1:COMP_CWORD-1}"; do
        child="$(__src_complete_child "$base" "$word")" || return 0
        base="$child"
    done

    [ -d "$base" ] || return 0

    for child in "$base"/*; do
        [ -d "$child" ] || continue
        name="${child##*/}"
        clean="${name%.git}"

        if [[ "$name" == "$cur"* || "$clean" == "$cur"* ]]; then
            candidates+=("$clean")
        fi
    done

    mapfile -t COMPREPLY < <(compgen -W "${candidates[*]}" -- "$cur")
}
complete -F __src_complete src
