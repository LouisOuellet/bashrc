#Adding /sbin to PATH
export PATH="$PATH:/sbin"

# Gathering Network
IP1=$(ip a | grep "inet " | egrep -v "127.0.0.1" | head -n 1 | awk '{ print $2 }')

#Editing prompt
PS1="\[\033[0;39m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[01;94m\]\u\[\033[01;92m\]@\[\033[01;94m\]\h'; fi)\[\033[0;39m\]]\342\224\200[\[\033[01;31m\]${IP1}\033[0;39m\]]\342\224\200[\[\033[01;36m\]\w\[\033[0;39m\]]\n\[\033[0;39m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;39m\]\\$\[\e[0m\] "

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
