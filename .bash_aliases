# Make ls Readable
alias ls="ls -lh"
# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls="ls -lh --color"
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# One line update system
alias update="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
# One line upgrade system
alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
# Create a new ssh function to setup bash on the remote machine
# Make sure to leave the function at the end of .bash_aliases
bssh(){
	rc=$(cat ${HOME}/.bashrc | base64 -w 0)
	profile=$(cat ${HOME}/.bash_profile | base64 -w 0)
	aliases=$(cat ${HOME}/.bash_aliases | head -n -9 | base64 -w 0)
	/usr/bin/ssh -Xt $@ "echo \"${rc}${profile}${aliases}\" | base64 --decode > /tmp/${USER}_bashrc; bash --rcfile /tmp/${USER}_bashrc; rm /tmp/${USER}_bashrc;"
}
tssh(){
	/usr/bin/ssh -Xt $@ 'tcsh;'
}
