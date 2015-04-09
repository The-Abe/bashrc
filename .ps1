BIYellow="\[\033[1;93m\]"
BIPurple="\[\033[1;95m\]"
BICyan="\[\033[1;96m\]"

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
function parse_hg_branch {
  hg branch 2>/dev/null
}
function parse_git_changes {
  mod=$(git status 2>/dev/null | grep -c modified)
  if [ $mod -gt 0 ]; then
    echo " +"
  fi
}
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
function parse_branches {
  branch=$(parse_git_branch)$(parse_hg_branch)
  if [ ! -z "$branch" ]; then
    echo " ($branch"
  else
    echo ""
  fi
}
function parse_changes {
  changes=$(parse_git_changes)$(parse_hg_changes)
  if [ ! -z "$branch" ]; then
    echo "$changes)"
  else
    echo ""
  fi
}
PROMPT_COMMAND=set_bash_prompt

function set_bash_prompt {
  branch=$(parse_branches)
  changes=$(parse_changes)
  PS1="$BICyan\w\n$BIPurple\$$BIYellow$branch$changes\[$(tput sgr0)\] "
}
