#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

function cdd()
{
   cd "$@" | ls -alh
}

alias ls='ls --color=auto'
export LANG=en_GB.UTF-8
PS1="[$(uptime | sed 's/: /\n/g' | tail -1) \u@\h \W]\$ "
export TERM=xterm
