# Adding /sbin to PATH
export PATH="$PATH:/sbin"

# Identify OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    CYGWIN*)    OS=Cygwin;;
    MINGW*)     OS=MinGw;;
    *)          OS="UNKNOWN:${unameOut}"
esac

# Gathering Network
if [ "$(whereis ifconfig | awk '{ print $1 }')" == '/sbin/ifconfig' ]; then
  IP1=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{ print $2 }' | tail -n 1)
else
  IP1=$(ip a | grep "inet " | egrep -v "127.0.0.1" | head -n 1 | awk '{ print $2 }')
fi

# COLORS
blackText=$(tput setaf 0)   # Black
redText=$(tput setaf 1)     # Red
greenText=$(tput setaf 2)   # Green
yellowText=$(tput setaf 3)  # Yellow
blueText=$(tput setaf 4)    # Blue
magentaText=$(tput setaf 5) # Magenta
cyanText=$(tput setaf 6)    # Cyan
whiteText=$(tput setaf 7)   # White
resetText=$(tput sgr0)      # Reset to default color

# STYLES
boldText=$(tput bold)
blinkingText=$(tput blink)
dimText=$(tput dim)

# Editing prompt
# ]\342\224\200[ => ]-[
PS1="\[\033[0;39m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[01;94m\]\u\[\033[01;92m\]@\[\033[01;94m\]\h'; fi)\[\033[0;39m\]]\342\224\200[\[\033[01;31m\]${IP1}\033[0;39m\]]\342\224\200[\[\033[01;36m\]\w\[\033[0;39m\]]\n\[\033[0;39m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;39m\]\\$\[\e[0m\] "
#PS1="\[\033[0;39m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")["
#PS1="$(if [[ ${EUID} == 0 ]]; then echo '\[${redText}root\[${yellowText}@\[${redText}\h'; else echo '\[${blueText}\u\[${greenText}@\[${blueText}\h'; fi)\[${resetText}]\342\224\200[${redText}${IP1}${resetText}]\342\224\200[${yellowText}${OS}${resetText}]\342\224\200[\[${cyanText}\w\[${resetText}]\n\[${resetText}\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;39m\]\\$\[\e[0m\] "

# Make ls Readable
alias ls="ls -lh"

# Adding common ALIASES
alias upmain='git add . && git commit -m '\''UPDATE'\'' && git push origin main'
alias fetchmain='git pull origin main'
alias upmaster='git add . && git commit -m '\''UPDATE'\'' && git push origin master'
alias fetchmaster='git pull origin master'

# Enable color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Handling OSes
if [ "$OS" == "Mac" ]; then
	export EDITOR=nano
	export VISUAL="$EDITOR"
	alias ls="ls -lhG"
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	alias upconnect='git add . && git commit -m '\''UPDATE'\'' && git push origin dev && git checkout beta && git merge dev && git push origin beta && git checkout dev'
	alias fetchconnect='git pull origin dev && git pull origin beta && git pull origin master'
	alias fetchjson="scp manager@albcie.com:json/*.json ${HOME}/Projects/ALB-Connect/config/."

	# Homebrew Integration
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# iTerm2 Integration
	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
else
  if [ -x /usr/bin/dircolors ]; then
    alias ls="ls -lh --color"
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
  fi
  if [ "$(whereis apt-get | awk '{ print $2 }')" != '' ]; then
    # One line update system
    alias update="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
    # One line upgrade system
    alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
  fi
fi
