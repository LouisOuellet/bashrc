# Some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# Make ls Readable
alias ls="ls -lh --color"
# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# Enable X Redirection on SSH sessions
alias ssh='ssh -X'
# One line update my system
alias update="sudo apt-get update && sudo sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
# One line upgrade my system
alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
