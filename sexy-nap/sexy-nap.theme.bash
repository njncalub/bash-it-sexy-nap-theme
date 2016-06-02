VIRTUAL_PROMPT_ENABLED=1

if [[ $COLORTERM = gnome-* && $TERM = xterm ]]  && infocmp gnome-256color >/dev/null 2>&1; then export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color >/dev/null 2>&1; then export TERM=xterm-256color
fi

if tput setaf 1 &> /dev/null; then
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        MAGENTA=$(tput setaf 9)
        ORANGE=$(tput setaf 172)
        GREEN=$(tput setaf 190)
        PURPLE=$(tput setaf 141)
        WHITE=$(tput setaf 0)
    else
        MAGENTA=$(tput setaf 5)
        ORANGE=$(tput setaf 4)
        GREEN=$(tput setaf 2)
        PURPLE=$(tput setaf 1)
        WHITE=$(tput setaf 7)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    MAGENTA="\033[1;31m"
    ORANGE="\033[1;33m"
    GREEN="\033[1;32m"
    PURPLE="\033[1;35m"
    WHITE="\033[1;37m"
    BOLD=""
    RESET="\033[m"
fi

function parse_git_dirty () {
    [[ $(git status 2> /dev/null | tail -n1 | cut -c 1-17) != "nothing to commit" ]] && echo "*"
}

function parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function parse_virtualenv () {
    if [[ $VIRTUAL_ENV ]]; then
        PARENT_ENV_DIR="$(dirname "$VIRTUAL_ENV")"
        ENV_DIR="${PARENT_ENV_DIR##*/}"
        
        if [[ $ENV_DIR == ".virtualenvs" ]]; then
            echo "(${VIRTUAL_ENV##*/}) "
        else
            echo "($ENV_DIR) "
        fi
    fi
}

function prompt_command() {
    if [[ $VIRTUAL_PROMPT_ENABLED == 1 ]]; then
        VIRTUALENV_PREFIX=$(parse_virtualenv)
    else
        VIRTUALENV_PREFIX=''
    fi
    
    PS1="$VIRTUALENV_PREFIX\[${BOLD}${MAGENTA}\]\u\[$WHITE\]x\[$ORANGE\]\h \[$WHITE\]in \[$GREEN\]\w\[$WHITE\]\[$WHITE\]\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \")\[$PURPLE\]\$(parse_git_branch)\[$WHITE\] \n\$ \[$RESET\]"
}

PROMPT_COMMAND=prompt_command

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
