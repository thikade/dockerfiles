test -z "$SSH_AGENT_PID" && eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa

export PS1="\u@\h \w > "
export TERM=xterm
export HISTFILESIZE=10000
export HISTSIZE=10000

alias gs="clear; git status"
alias gd="clear; git diff"
alias gb="clear; git branch"
alias gc="clear; git commit"
alias gl="clear; git log"
alias ga="clear; git add"

alias ll='ls -al'
