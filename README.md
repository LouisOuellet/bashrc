# BASHRC

This Repository simply contains some personalized bash profile files. It includes support for Ubuntu, Debian, Rasbian, Arch and macOS.


## Terminal Prompt

```bash
┌─[user@hostname]─[0.0.0.0/24]─[~]
└──╼ $
```

## Aliases

```bash
alias ls="ls -lh --color"
alias upmain='git add . && git commit -m '\''UPDATE'\'' && git push origin main'
alias fetchmain='git pull origin main'
alias upmaster='git add . && git commit -m '\''UPDATE'\'' && git push origin master'
alias fetchmaster='git pull origin master'
```

## Functions

### piKVM
This function opens Google Chrome as a web app to the specified PiKVM. If you are missing some arguments, it will ask for the necessary information.

#### Usage
```bash
piKVM [IP]
```
### saveDMG
This function can be used to backup a disk into a dmg file. If you are missing some arguments, it will ask for the necessary information.

#### Usage
```bash
saveDMG [disk]
```

### restoreDMG
This function can be used to restore a dmg onto a disk. If you are missing some arguments, it will ask for the necessary information.

#### Usage
```bash
restoreDMG [dmg] [disk]
```

### scanPort
This function will scan a network for all ip that have a specified port open. If you are missing some arguments, it will ask for the necessary information.

#### Usage
```bash
scanPort [network/cidr or network] [mask or cidr] [port]
```

### toCIDR
This function converts a subnet mask like 255.255.255.0 to 24.

#### Usage
```bash
toCIDR 255.255.255.0
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

## Extra for Linux

### Aliases for Debian base Distributions
```bash
alias update="sudo apt-get update && sudo sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
alias checkUpdate="sudo apt list --upgradable"
```

### Aliases for Ubuntu base Distributions
```bash
alias setCLI="sudo systemctl set-default multi-user && echo You need to reboot the system"
alias setGUI="sudo systemctl set-default graphical && echo You need to reboot the system"
```

### Aliases for Arch base Distributions
```bash
alias update="sudo pacman -Syu"
```
