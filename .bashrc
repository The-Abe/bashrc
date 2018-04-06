# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# The pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

function color() {
  echo -e "\033[38;5;$1m"
}
function bold() {
 echo -e "\e[1m"
}
function reset_color() {
 echo -e "\e[m"
}

hg_branch() {
  hg branch 2> /dev/null | awk '{printf "hg:" $1}'
}

hg_dirty() {
  stat=$(hg status 2> /dev/null \
    | awk '{print $1}' \
    | sort | uniq | paste -sd '' -)
  if [[ $stat != "" ]]
  then
    echo ":$stat"
  fi
}

git_branch() {
  branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ $branch != "" ]]
  then
    echo "git:$branch"
  fi
}

git_dirty() {
  stat=$(git status --porcelain 2>/dev/null \
    | awk '{print $1}' \
    | sort | uniq | paste -sd '' -)
  if [[ $stat != "" ]]
  then
    echo ":$stat"
  fi
}

return_code() {
  res=$?
  if [ $res != 0 ]
  then
    echo -e "$(bold)$(color 197)✘($res) "
  else
    echo -e "$(bold)$(color 82)✔ "
  fi
}

#Molokai colours
#197
#81
#202
#82
#144
#99
prompt() {
  echo -e "\n$(return_code)$(color 81)$(whoami) $(reset_color)at $(bold)$(color 202)$(hostname) $(reset_color)in $(bold)$(color 197)$(dirs) $(reset_color)$(color 144)$(hg_branch)$(git_branch)$(hg_dirty)$(git_dirty)$(reset_color)"
}
PROMPT_COMMAND=prompt
PS1="$ "
PS4='$0.$LINENO: '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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
if [[ -f ~/.ssh/id_rsa.pub ]]
then
  if [ ! -S ~/.ssh/ssh_auth_sock ]
  then
    eval `ssh-agent`
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
  fi
  export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
  ssh-add -l | grep "The agent has no identities" && ssh-add
fi
