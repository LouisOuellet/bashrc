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

## Extra Settings for macOS

```bash
# Homebrew Integration
eval "$(/opt/homebrew/bin/brew shellenv)"
# iTerm2 Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
```

## Aliases for Debian base Distributions

```bash
alias update="sudo apt-get update && sudo sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
```
