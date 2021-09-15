# BASHRC

This Repository simply contains some personalized bash profile files.


## Terminal Prompt

```bash
┌─[user@hostname]─[0.0.0.0/24]─[~]
└──╼ #
```

## Aliases

```bash
alias ls="ls -lh --color"
alias upmain='git add . && git commit -m '\''UPDATE'\'' && git push origin main'
alias fetchmain='git pull origin main'
alias upmaster='git add . && git commit -m '\''UPDATE'\'' && git push origin master'
alias fetchmaster='git pull origin master'
```

## Extra for macOS

### Settings
```bash
# Homebrew Integration
eval "$(/opt/homebrew/bin/brew shellenv)"
# iTerm2 Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
# Export PATH for MAMP
export PATH=/Applications/MAMP/Library/bin/:$PATH
export PATH=/Applications/MAMP/bin/php/php7.4.16/bin:$PATH
```

### Functions
#### burnWin10ISO
This funtion provides an easy way to burn a Windows 10 ISO onto a USB. It also does several checks to avoid potential harm to your computer.

##### Usage
```bash
burnWin10ISO disk iso.file
```

## Aliases for Debian base Distributions

```bash
alias update="sudo apt-get update && sudo sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
```
