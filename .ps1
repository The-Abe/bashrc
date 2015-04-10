# Author: Abe van der Wielen
# Date: 2015-04-10
# Email: abevanderwielen@gmail.com
# Website: https://github.com/the-abe
# File: .ps1
#
# Source this file in .bashrc to get my fancy schmancy PS1 prompt.
# Example:
#   ~/bashrc
#   $ (master +) echo "test"


#COLOR Definitions
BIYellow="\[\033[1;93m\]"
BIPurple="\[\033[1;95m\]"
BICyan="\[\033[1;96m\]"
BIBlue="\[\033[1;34m\]"

# Return just the git branch name
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# Return just the hg branch name
function parse_hg_branch {
  hg branch 2>/dev/null
}
function parse_git_changes {
  mod=$(git status 2>/dev/null | grep -c modified)
  if [ $mod -gt 0 ]; then
    echo " +"
  fi
}

# Return a string based on the changes in hg status
# + for modified files
# ? for untracked files
function parse_hg_changes {
  st=$(hg st 2>/dev/null)
  add=$(echo $st | grep -c "? app" | grep -v "\.orig$")
  mod=$(echo $st | grep -c "^[MARC]")
  if [ $mod -gt 0 ] && [ $add -gt 0 ]; then
    echo " +?"
  elif [ $add -gt 0 ]; then
    echo " ?"
  elif [ $mod -gt 0 ]; then
    echo " +"
  fi
}

# Return a string for both the git and hg branches
function parse_branches {
  branch=$(parse_git_branch)$(parse_hg_branch)
  if [ ! -z "$branch" ]; then
    echo " ($branch"
  else
    echo ""
  fi
}

# Return a string for both the git and hg changes
function parse_changes {
  changes=$(parse_git_changes)$(parse_hg_changes)
  if [ ! -z "$branch" ]; then
    echo "$changes)"
  else
    echo ""
  fi
}

# Run this command every time a prompt shows up.
# If we just define PS1 and the command output it only runs the first time.
PROMPT_COMMAND=set_bash_prompt

# Get the branch and changes string and put it in PS1
function set_bash_prompt {
  branch=$(parse_branches)
  changes=$(parse_changes)
  # Path \n $/# git/hg
  #PS1="$BICyan\w\n$BIPurple\$$BIYellow$branch$changes\[$(tput sgr0)\] "
  PS1="$BICyan\w\n$BIPurple\$$BIYellow$branch$changes$BIBlue "
}

trap '[[ -t 1 ]] && tput sgr0' DEBUG
# vim:ft=sh
