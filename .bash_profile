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
alias ls="ls -lh --group-directories-first"
# alias cpr='rsync -ur --progress'
# alias mvr='rsync -ur --progress --remove-sent-files'
# Requirements

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

  function piKVM {
    kvm=
    if [[ $1 != "" ]]; then kvm=$1; fi
    if [[ $kvm == "" ]]; then echo "KVM IP?"; read kvm; fi
    echo "Connecting to $kvm"
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app="https://$kvm/"
  }

  function toCIDR {
    c=0 x=0$( printf '%o' ${1//./ } )
    while [ $x -gt 0 ]; do
      let c+=$((x%2)) 'x>>=1'
    done
    echo $c
  }

  function scanPort {
    # Install requirements
    if [[ $(brew list --version nmap) == "" ]]; then
      brew install nmap
    fi
    # INIT all variables
    network=
    port=
    mask=
    cidr=
    ipcidr=
    scan=
    input=
    # Handle input
    if [[ $3 != "" ]];then
      network=$1
      port=$3
      if [[ $2 == *"."* ]]; then mask=$2; else cidr=$2; fi
    else
      if [[ $2 != "" ]];then
        if [[ $1 == *"/"* ]]; then ipcidr=$1; else network=$1; fi
        if [[ $2 == *"."* ]]; then mask=$2; else cidr=$2; fi
        if [[ $ipcidr != "" ]]; then port=$2; fi
      else
        if [[ $1 != "" ]];then
          if [[ $1 == *"/"* ]]; then ipcidr=$1; else network=$1; fi
        fi
      fi
    fi
    # Build scan profile
    while [[ $scan == "" ]];do
      if [[ $ipcidr != "" ]] && [[ $port != "" ]]; then scan="${port} ${ipcidr}"; fi
      if [[ $port == "" ]]; then echo "Which port are you scanning?"; read port; fi
      if [[ $network != "" ]] && [[ $cidr != "" ]]; then ipcidr="${network}/${cidr}"; fi
      if [[ "${network}${ipcidr}" == "" ]]; then
        echo "What network do you want to scan?(0.0.0.0/24)"
        read input
        if [[ $input == *"/"* ]]; then ipcidr=$input; else network=$input; fi
      fi
      if [[ "${mask}${cidr}${ipcidr}" == "" ]]; then
        echo "What is the subnet mask?(CIDR or 255.255.255.0)"
        read input
        if [[ $input == *"."* ]]; then mask=$input; else cidr=$input; fi
      fi
      if [[ $cidr == "" ]] && [[ $mask != "" ]]; then cidr=$(toCIDR $mask); fi
    done
    # Start Scanning
    nmap -Pn -p ${scan} | egrep -B 4 "open" | grep for | awk '{ print $5 }'
  }

  function scanIP {
    # Install requirements
    if [[ $(brew list --version nmap) == "" ]]; then
      brew install nmap
    fi
    # INIT all variables
    network=
    mask=
    cidr=
    ipcidr=
    input=
    # Handle input
    if [[ $2 != "" ]];then
      if [[ $1 == *"/"* ]]; then ipcidr=$1; else network=$1; fi
      if [[ $2 == *"."* ]]; then mask=$2; else cidr=$2; fi
      if [[ $ipcidr != "" ]]; then port=$2; fi
    else
      if [[ $1 != "" ]];then
        if [[ $1 == *"/"* ]]; then ipcidr=$1; else network=$1; fi
      fi
    fi
    # Build scan profile
    while [[ $ipcidr == "" ]];do
      if [[ $network != "" ]] && [[ $cidr != "" ]]; then ipcidr="${network}/${cidr}"; fi
      if [[ "${network}${ipcidr}" == "" ]]; then
        echo "What network do you want to scan?(0.0.0.0/24)"
        read input
        if [[ $input == *"/"* ]]; then ipcidr=$input; else network=$input; fi
      fi
      if [[ "${mask}${cidr}${ipcidr}" == "" ]]; then
        echo "What is the subnet mask?(CIDR or 255.255.255.0)"
        read input
        if [[ $input == *"."* ]]; then mask=$input; else cidr=$input; fi
      fi
      if [[ $cidr == "" ]] && [[ $mask != "" ]]; then cidr=$(toCIDR $mask); fi
    done
    # Start Scanning
    nmap -sn -n ${ipcidr} | grep report | awk '{ print $5 }'
  }

  function restoreDMG {
    if [[ $(brew list --version pv) == "" ]]; then
      brew install pv
    fi
    if [[ $1 != "" ]] || [[ $1 == *"dmg"* ]]; then
      dmg=$1
      if [[ $2 == "" ]] || [[ $2 != *"disk"* ]]; then
        for disk in $(diskutil list | grep disk | egrep -v '\(' | grep 0: | awk '{ print $NF }');do
          if [[ $(diskutil info /dev/$disk | grep 'Protocol' | awk '{ print $NF}') == "USB" ]] && [[ $(diskutil info /dev/$disk | grep 'APFS Physical Store') == "" ]]; then
            diskutil list $disk
          fi
        done
        echo "Wich disk do you want to use?"
        read disk
      else
        disk=$2
      fi
      echo "Restoring $dmg into /dev/$disk"
      for partition in $(diskutil list $disk | grep $disk | egrep -v '0:' | egrep -v '/dev/' | awk '{ print $NF }');do
        echo "Unmounting $partition"
        diskutil unmount $partition
      done
      pv -tpreb $dmg | sudo dd of=/dev/$disk
      for partition in $(diskutil list $disk | grep $disk | egrep -v '0:' | egrep -v '/dev/' | awk '{ print $NF }');do
        echo "Unmounting $partition"
        diskutil unmount $partition
      done
      echo "$disk is ready!"
      echo "You can safely remove $disk"
    else
      echo "Please specify a dmg file to restore"
    fi
  }

  function saveDMG {
    if [[ $(brew list --version pv) == "" ]]; then
      brew install pv
    fi
    if [[ $1 != "" ]] || [[ $1 == *"dmg"* ]]; then
      dmg=$1
      if [[ $2 == "" ]] || [[ $2 != *"disk"* ]]; then
        for disk in $(diskutil list | grep disk | egrep -v '\(' | grep 0: | awk '{ print $NF }');do
          if [[ $(diskutil info /dev/$disk | grep 'Protocol' | awk '{ print $NF}') == "USB" ]] && [[ $(diskutil info /dev/$disk | grep 'APFS Physical Store') == "" ]]; then
            diskutil list $disk
          fi
        done
        echo "Wich disk do you want to use?"
        read disk
      else
        disk=$2
      fi
      echo "Saving /dev/$disk into $dmg"
      for partition in $(diskutil list $disk | grep $disk | egrep -v '0:' | egrep -v '/dev/' | awk '{ print $NF }');do
        echo "Unmounting $partition"
        diskutil unmount $partition
      done
      pv -tpreb /dev/$disk | sudo dd of=$dmg
    else
      echo "Please specify a dmg file name"
    fi
  }

  function compileAppMaker {
    directory=$(pwd)
    plugins=
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
          plugin=$(echo $plugin | sed -e 's/\/Volumes\/Projects\/appmaker-//g')
          if [[ $plugins == "" ]]; then
            plugins=${plugin}
          else
            plugins="${plugins} ${plugin}"
          fi
          php compile.php
        fi
      fi
    done
    cd /Volumes/Projects/appmaker
    for plugin in $plugins;do
      json='{"plugin":"'$plugin'"}'
      php cli.php --update "$json"
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
  # QUOTE="true";

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
  # Get Distribution and Architecture
  if [[ "$OS" == "Linux" ]]; then
    Distribution=$(hostnamectl | grep 'Operating System' | awk '{ print $3 }')
    Architecture=$(hostnamectl | grep 'Architecture' | awk '{ print $2 }')
    if [[ "$(hostnamectl | grep 'Hardware Vendor' | awk '{ print $3 }')" == "QEMU" ]]; then
      isVM=true
    else
      isVM=false
    fi
    # Functions
    function install {
      if [[ "$1" != '' ]]; then
        pkg=$1
      else
        echo "Please select a software to install:"
        echo " - UniFi_Controller"
      fi
      case $pkg in
        UniFi_Controller)
          echo "Installing UniFi Controller"
          wget "https://github.com/LouisOuellet/UniFi/raw/master/install-unifi-pihole-English.sh" -O install-unifi-pihole.sh
          chmod +x install-unifi-pihole.sh
          ./install-unifi-pihole.sh no-pihole
          rm install-unifi-pihole.sh
          ;;
        PiKVM_OLED)
          rw
          systemctl enable --now kvmd-oled kvmd-oled-reboot kvmd-oled-shutdown
          systemctl enable --now kvmd-fan
          ro
          ;;
        *)
          echo "There is no installation script for $pkg"
          ;;
      esac
    }
    case $Distribution in
      Arch)
        ;;
      Debian|Ubuntu)
        if [[ "$Distribution" == "Ubuntu" ]]; then
          # Adding aliases to enable/disable GUI Desktop
          alias setCLI="sudo systemctl set-default multi-user && echo You need to reboot the system"
          alias setGUI="sudo systemctl set-default graphical && echo You need to reboot the system"
        fi
        if [ "$(whereis apt-get | awk '{ print $2 }')" != '' ]; then
          # Installing some packages
          if [ "$(whereis toilet | awk '{ print $2 }')" == '' ]; then
            sudo apt-get install -y toilet
          fi
          if [ "$(whereis cowsay | awk '{ print $2 }')" == '' ]; then
            sudo apt-get install -y cowsay
          fi
          if [ "$(whereis linuxlogo | awk '{ print $2 }')" == '' ]; then
            sudo apt-get install -y linuxlogo
          fi
          if [ "$(whereis figlet | awk '{ print $2 }')" == '' ]; then
            sudo apt-get install -y figlet
          fi
          # One line update system
          alias update="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
          # One line upgrade system
          alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
          # One line check update
          alias checkUpdate="sudo apt list --upgradable"
        fi
        ;;
      *);;
    esac
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
  if [[ "$Distribution" == "Ubuntu" ]] || [[ "$Distribution" == "Debian" ]] || [[ "$OS" == "Mac" ]]; then
    if [[ $EUID -ne 0 ]]; then
      if [[ "$OS" == "Linux" ]]; then
        linuxlogo -u -y -b
      fi
    else
      echo
      toilet -f smblock --filter border -w 120 ' Careful!   You are now root! '
    fi
  fi
  echo
  echo -ne "Good Morning, $USER! It's "; date '+%A, %B %-d %Y'
  echo
  if [ "${QUOTE}" == "true" ]; then
    # French Love Citation of the day
    echo $(curl -s https://www.mon-poeme.fr/citation-amour-du-jour/ | grep '<div class="post">' | sed -e '1q;d' | sed -e 's/<[^>]*>//g')
    echo
  fi
fi
