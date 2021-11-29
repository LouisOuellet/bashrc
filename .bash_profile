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

if [[ $- == *i* ]]; then
  # COLORS
  blackText=$(tput setaf 0)           # Black
  redText=$(tput setaf 1)             # Red
  greenText=$(tput setaf 2)           # Green
  yellowText=$(tput setaf 3)          # Yellow
  blueText=$(tput setaf 4)            # Blue
  magentaText=$(tput setaf 5)         # Magenta
  cyanText=$(tput setaf 6)            # Cyan
  whiteText=$(tput setaf 7)           # White
  greyText=$(tput setaf 8)            # Grey
  lightredText=$(tput setaf 9)        # Light Red
  lightgreenText=$(tput setaf 10)     # Light Green
  lightyellowText=$(tput setaf 11)    # Light Yellow
  lightblueText=$(tput setaf 12)      # Light Blue
  lightmagentaText=$(tput setaf 13)   # Light Magenta
  lightcyanText=$(tput setaf 14)      # Light Cyan
  lightgreyText=$(tput setaf 15)      # Light Grey
  resetText=$(tput sgr0)              # Reset to default color

  # STYLES
  boldText=$(tput bold)
  blinkingText=$(tput blink)
  dimText=$(tput dim)
fi

# Make ls Readable
alias ls="ls -lh"

# Enable color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Configure Editor
export EDITOR=/usr/bin/nano

# Handling OSes
if [ "$OS" == "Mac" ]; then
	export EDITOR=nano
	export VISUAL="$EDITOR"

  # Adding homebrew
  export PATH=/opt/homebrew/bin/:$PATH

  # Silence Terminal
  export BASH_SILENCE_DEPRECATION_WARNING=1
	alias ls="ls -lhG"
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
  if [ ! -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    if [[ $(brew list --version bash) == "" ]]; then
      brew install bash
    fi
    if [[ $(brew list --version bash-completion) == "" ]]; then
      brew install bash-completion
    fi
    if [[ $(brew list --version git) == "" ]]; then
      brew install git
    fi
  fi
  if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
  fi
  if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]; then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
  fi

  function compileAppMaker {
    directory=$(pwd)
    for plugin in /Volumes/Projects/*; do
      if [[ $plugin == *"appmaker-"* ]]; then
        if [[ $plugin != *"appmaker-plugins"* ]]; then
          if [[ -f /Volumes/Projects/appmaker-plugins/compile.php ]]; then
            cp /Volumes/Projects/appmaker-plugins/compile.php "${plugin}/compile.php"
            if [[ -f /Volumes/Projects/appmaker-plugins/settings.json ]]; then
              cp /Volumes/Projects/appmaker-plugins/settings.json "${plugin}/settings.json"
            fi
          fi
        fi
        cd $plugin
        if [[ "$(git status | grep Changes)$(git status | grep Untracked)" != '' ]]; then
          echo ""
          echo "==============================================="
          echo $plugin
          echo "==============================================="
          php compile.php
        fi
      fi
    done
    cd $directory
  }

  function publishAppMaker {
    if [[ $1 != "" ]]; then
      branch=$1
    else
      branch=pre-release
    fi
    directory=$(pwd)
    for plugin in /Volumes/Projects/*; do
      if [[ $plugin == *"appmaker-"* ]]; then
        cd $plugin
        echo ""
        echo "==============================================="
        echo $plugin
        echo "==============================================="
        current=$(git rev-parse --abbrev-ref HEAD)
        php compile.php
        git checkout -b ${branch}
        git checkout ${branch}
        git merge ${current}
        php compile.php
        git checkout ${current}
        git merge ${branch}
        php compile.php
      fi
    done
    cd /Volumes/Projects/appmaker
    php cli.php --publish
    git checkout -b ${branch}
    git checkout ${branch}
    git merge ${current}
    php cli.php --publish
    git checkout ${current}
    git merge ${branch}
    php cli.php --publish
    cd $directory
  }

  function burnWin10ISO {
    if [[ $(brew list --version wimlib) == "" ]]; then
      brew install wimlib
    fi
    if [[ $1 != "" ]]; then
      if [[ $1 == "disk"* ]]; then
        INFO=$(diskutil info $1 | grep "Protocol:" | awk '{ print $2 }')
        if [[ $INFO == *"USB"* ]]; then
          if [[ $2 == *".iso" ]]; then
            if [ -f "${2}" ]; then
              diskutil eraseDisk MS-DOS 'WIN10' GPT /dev/${1}
              hdiutil mount ${2}
              rsync -vha --exclude=sources/install.wim /Volumes/CCCOMA_X64FRE_EN-US_DV9/* /Volumes/WIN10
              mkdir -p /Volumes/WIN10/sources
              wimlib-imagex split /Volumes/CCCOMA_X64FRE_EN-US_DV9/sources/install.wim /Volumes/WIN10/sources/install.swm 3800
              diskutil unmount /dev/${1}
              diskutil eject /dev/${1}
              diskutil unmount /Volumes/CCCOMA_X64FRE_EN-US_DV9
              echo "${2} has been written on ${1}. You can now disconnect ${1} and start your installation."
            else
              echo "Unable to find ${2}."
            fi
          else
            echo "${2} is not an ISO file or you did not specify an ISO file."
          fi
        else
          echo "${1} is not available on this computer or is not a USB Drive. Here's the list:"
          diskutil list
        fi
      else
        echo "${1} is not a disk or you did not specify a disk. Here's the list:"
        diskutil list
      fi
    else
      echo "burnWin10ISO [disk] [iso file]"
    fi
  }

	# Homebrew Integration
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# iTerm2 Integration
	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

  # Adding common ALIASES
  alias upmain='git add . && git commit -m '\''UPDATE'\'' && git push origin main'
  alias fetchmain='git pull origin main'
  alias upmaster='git add . && git commit -m '\''UPDATE'\'' && git push origin master'
  alias fetchmaster='git pull origin master'
  alias upbeta='git add . && git commit -m '\''UPDATE'\'' && git push origin beta'
  alias fetchbeta='git pull origin beta'
  alias updev='git add . && git commit -m '\''UPDATE'\'' && git push origin dev'
  alias fetchdev='git pull origin dev'
  alias projects='cd /Volumes/Projects'

  # Enable quote of the day
  QUOTE="true";

  if [ -d /Applications/MAMP ]; then
    # Export PATH for MAMP
    export PATH=/Applications/MAMP/Library/bin/:$PATH
    export PATH=/Applications/MAMP/bin/php/php7.4.16/bin:$PATH
    alias php='/Applications/MAMP/bin/php/php7.4.16/bin/php -c "/Library/Application Support/appsolute/MAMP PRO/conf/php7.4.16.ini"'
    alias composer='/Applications/MAMP/bin/php/composer'
    alias php-config='/Applications/MAMP/bin/php/php7.4.16/bin/php-config'
    alias phpdbg='/Applications/MAMP/bin/php/php7.4.16/bin/phpdbg'
    alias phpize='/Applications/MAMP/bin/php/php7.4.16/bin/phpize'
    alias pear='/Applications/MAMP/bin/php/php7.4.16/bin/pear'
    alias peardev='/Applications/MAMP/bin/php/php7.4.16/bin/peardev'
    alias pecl='/Applications/MAMP/bin/php/php7.4.16/bin/pecl'
  fi

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

# Loading custom settings
if [ -x ~/.profile ]; then
  source ~/.profile
fi
if [ -x ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

# Editing prompt
# ┌ = \342\224\214
# - = \342\224\200
# └ = \342\224\224
# ╼ = \342\225\274

if [[ ${EUID} == 0 ]]; then
  pUSER="[${lightredText}\u${lightyellowText}@${lightblueText}\h${resetText}]"
else
  pUSER="[${lightblueText}\u${lightgreenText}@${lightblueText}\h${resetText}]"
fi
pIP="[${redText}${IP1}${resetText}]"
pCWD="[${lightcyanText}\w${resetText}]"
pGIT='$(__git_ps1 "\342\224\200[${lightgreenText}%s${resetText}]")'
PS1="\342\224\214\342\224\200${pUSER}\342\224\200${pIP}\342\224\200${pCWD}${pGIT}"
PS1="${PS1}\n\342\224\224\342\224\200\342\224\200\342\225\274 $ "

# Greetings
if [[ $- == *i* ]]; then
  echo
  echo -ne "Good Morning, $USER! It's "; date '+%A, %B %-d %Y'
  echo
  if [ "${QUOTE}" == "true" ]; then
    # French Love Citation of the day
    echo $(curl -s https://www.mon-poeme.fr/citation-amour-du-jour/ | grep '<div class="post">' | sed -e '1q;d' | sed -e 's/<[^>]*>//g')
    echo
  fi
fi
