#!/bin/bash
#==============================================================================
#TITLE:            bash_profile
#DESCRIPTION:      This profile include support for all oses (macOS, Ubuntu, Debian, Rasbian, Arch)
#AUTHOR:           Louis Ouellet
#DATE:             2022-03-02
#VERSION:          22.03-02

#==============================================================================
# BASH SETUP
#==============================================================================

# Adding /sbin to PATH
export PATH="$PATH:/sbin"

# Set Bash
set -o pipefail

#==============================================================================
# GATHERING SYSTEM INFORMATION
#==============================================================================

# Identify OS
unameOut="$(uname -s)"
case "${unameOut}" in
  Linux*)     OS=Linux;;
  Darwin*)    OS=Mac;;
  CYGWIN*)    OS=Windows;;
  MINGW*)     OS=MinGw;;
  *)          OS="UNKNOWN:${unameOut}"
esac

# Identify Distribution
Distribution=
Architecture=
PackageManager=
case $OS in
  Linux)
    Distribution=$(hostnamectl | grep 'Operating System' | cut -d: -f2 | xargs)
    Architecture=$(uname -p)
    if [[ "$(whereis pacman | awk '{ print $2 }')" != '' ]]; then PackageManager="pacman"; fi
    if [[ "$(whereis yum | awk '{ print $2 }')" != '' ]]; then PackageManager="yum"; fi
    if [[ "$(whereis dnf | awk '{ print $2 }')" != '' ]]; then PackageManager="dnf"; fi
    if [[ "$(whereis apt-get | awk '{ print $2 }')" != '' ]]; then PackageManager="apt-get"; fi
    ;;
  Mac)
    Distribution=$(sw_vers -productVersion)
    Architecture=$(uname -p)
    PackageManager="brew"
    ;;
  *);;
esac

# Gathering Network
if [[ "$(whereis ifconfig | awk '{ print $1 }')" == '/sbin/ifconfig' ]] || [[ "${OS}" == "Mac" ]]; then
  IP=$(ifconfig | grep "inet " | egrep -v 127.0.0.1 | awk '{ print $2 }' | tail -n 1)
else
  IP=$(ip a | grep "inet " | egrep -v "127.0.0.1" | head -n 1 | awk '{ print $2 }')
fi

#==============================================================================
# FORMATTING
#==============================================================================

function format(){
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
}

function clrformat(){
  # COLORS
  blackText=
  redText=
  greenText=
  yellowText=
  blueText=
  magentaText=
  cyanText=
  whiteText=
  greyText=
  lightredText=
  lightgreenText=
  lightyellowText=
  lightblueText=
  lightmagentaText=
  lightcyanText=
  lightgreyText=
  resetText=

  # STYLES
  boldText=
  blinkingText=
  dimText=
}

#==============================================================================
# ELEMENTS
#==============================================================================

function elements(){
  # CHECK BOXES
  checkBoxGood="[${greenText}✓${resetText}]"        # Good
  checkBoxBad="[${redText}✗${resetText}]"           # Bad
  checkBoxQuestion="[${magentaText}?${resetText}]"  # Question / ?
  checkBoxInfo="[${cyanText}i${resetText}]"         # Info / i
  checkBoxOutput="[${yellowText}!${resetText}]"     # Output / !

  # FRAMES
  frameTopLeft="\342\224\214"      # ┌
  frameBottomLeft="\342\224\224"   # └
  frameHline="\342\224\200"        # -
  frameHlineEnd="\342\225\274"     # ╼

  # Log Types
  INFO=$checkBoxInfo
  OUTPUT=$checkBoxOutput
  SUCCESS=$checkBoxGood
  ERROR=$checkBoxBad
  WARNING=$checkBoxOutput

  # Log Actions
  CHECK="[CHECK]"
  START="[START]"
  TIMED="[TIMED]"
  RUN="[ RUN ]"
  EMPT="[     ]"
  OUT="[ OUT ]"
  VAR="[ VAR ]"
}

function PDATE(){
  printf "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

#==============================================================================
# HELPERS
#==============================================================================

function error(){
  printf "FATAL ERROR: $1\n"
  exit 0
}

function dbg(){
  if [ "$1" != "" ] && [ "$2" != "" ]; then
    case "$1" in
      info|i)
        TYPE=$INFO
        ;;
      success|s)
        TYPE=$SUCCESS
        ;;
      error|e)
        TYPE=$ERROR
        ;;
      output|o)
        TYPE=$OUTPUT
        ;;
      warning|w)
        TYPE=$WARNING
        ;;
      question|q)
        TYPE=$checkBoxQuestion
        ;;
    esac
    case "$2" in
      check|c|test|t)
        ACTION=$CHECK
        ;;
      start|s)
        ACTION=$START
        ;;
      run|r)
        ACTION=$RUN
        ;;
      empty|e)
        ACTION=$EMPT
        ;;
      output|o)
        ACTION=$OUT
        ;;
      timed|t)
        ACTION=$TIMED
        ;;
      variable|var|v)
        ACTION=$VAR
        ;;
    esac
    while read DCMD; do
      if [ "$3" != "" ]; then
        LogFile=$3
      fi
			DCMDout=$(echo $DCMD | sed -e "s/\n/ /g")
			for string in ${protect[@]};do
				DCMDout=$(echo $DCMDout | sed -e "s/$string/xxx/g")
			done
      if [ "$DEBUG" = "true" ]; then
        printf "${TYPE}$(PDATE)${ACTION} ${DCMDout}\n" | tee -a $logs_file
      else
        printf "${TYPE}$(PDATE)${ACTION} ${DCMDout}\n"
      fi
    done
  else
    error "Missing Argument(s)"
  fi
}

function exec(){
  if [ "$1" != "" ]; then
    echo "exec $1" | dbg i s
    if eval $1 2>&1 | dbg o o;then
      echo "$1" | dbg s r
    else
      echo "$1" | dbg e r
    fi
  else
    error "Missing Argument(s)"
  fi
}

function pkg(){
  if [ "$1" != "" ]; then
    if [ "$DEBUG" = "true" ]; then
      echo "pkg $1" | dbg i s
    fi
    case $OS in
      Linux)
        if [[ "$(whereis $1 | awk '{ print $2 }')" == '' ]]; then
          case $PackageManager in
            pacman)
              exec "sudo pacman -S --noconfirm $1"
              ;;
            dnf)
              exec "sudo dnf install -y $1"
              ;;
            yum)
              exec "sudo yum install -y $1"
              ;;
            apt-get)
              exec "sudo apt-get update"
              exec "sudo apt-get install -y --fix-missing $1"
              ;;
            *)
              echo "Unable to install $1" | dbg e e
              echo "Unsupported Package Manager" | dbg e e
              ;;
          esac
        fi
        ;;
      Mac)
        if [[ $(brew list --version $1) == "" ]]; then
          exec "brew install $1"
        fi
        ;;
      *)
        echo "Unable to install $1" | dbg e e
        echo "Unsupported OS" | dbg e e
        ;;
    esac
  else
    error "Missing Argument(s)"
  fi
}

function send(){
  exec "echo \"$2\" | s-nail -s \"$1\" -S smtp-use-ssl -S ssl-rand-file=/tmp/mail.entropy -S smtp-auth=login -S smtp=\"smtps://${smtp_host}:${smtp_port}\" -S from=\"${send_from}(${send_name})\" -S smtp-auth-user=\"${smtp_username}\" -S smtp-auth-password=\"${smtp_password}\" -S ssl-verify=ignore -a \"$logs_file\" ${send_to}"
}

#==============================================================================
# SETTINGS
#==============================================================================

function protectDCMD(){
	protect=(
		$smtp_host
		$smtp_port
		$smtp_username
		$smtp_password
		$send_name
		$send_from
	)
}

function import(){
  if [[ -f "settings.json" ]]; then
    smtp_host=$(jq -r '.smtp.host' settings.json)
    smtp_port=$(jq -r '.smtp.port' settings.json)
    smtp_username=$(jq -r '.smtp.username' settings.json)
    smtp_password=$(jq -r '.smtp.password' settings.json)
    send_name=$(jq -r '.send.name' settings.json)
    send_from=$(jq -r '.send.from' settings.json)
    send_to=$(jq -r '.send.to' settings.json)
    logs_directory=$(jq -r '.logs.directory' settings.json)
  fi
  case $OS in
    Linux)
      logs_file="${logs_directory}$(date +%s%N).log"
      ;;
    Mac)
      logs_file="${logs_directory}$(date +%s).log"
      ;;
    *);;
  esac
	protectDCMD
}

#==============================================================================
# SOURCING
#==============================================================================

case $OS in
  Linux);;
  Mac)
    # Git Integration
    if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
      source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
    fi
    if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]; then
      source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
    fi
  	# Homebrew Integration
  	eval "$(/opt/homebrew/bin/brew shellenv)"
    # Adding homebrew
    export PATH=/opt/homebrew/bin/:$PATH
  	# iTerm2 Integration
  	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
    ;;
  *);;
esac

#==============================================================================
# REQUIREMENTS
#==============================================================================

pkg bash-completion
pkg git
pkg toilet
pkg cowsay

case $OS in
  Linux)
    pkg linuxlogo
    ;;
  Mac);;
  *);;
esac

#==============================================================================
# ALIASES
#==============================================================================

alias ls="ls -lh --group-directories-first"
alias upmain='git add . && git commit -m '\''UPDATE'\'' && git push origin main'
alias fetchmain='git pull origin main'
alias upmaster='git add . && git commit -m '\''UPDATE'\'' && git push origin master'
alias fetchmaster='git pull origin master'
alias upbeta='git add . && git commit -m '\''UPDATE'\'' && git push origin beta'
alias fetchbeta='git pull origin beta'
alias updev='git add . && git commit -m '\''UPDATE'\'' && git push origin dev'
alias fetchdev='git pull origin dev'
if [ -x /usr/bin/dircolors ]; then
  alias ls="ls -lh --color --group-directories-first"
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

case $OS in
  Linux)
    case $Distribution in
      Ubuntu|Debian)
        alias update="sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y"
        alias upgrade="sudo apt install update-manager-core -y && sudo do-release-upgrade -y"
        alias checkUpdate="sudo apt list --upgradable"
        if [[ "$Distribution" == "Ubuntu" ]]; then
          alias setCLI="sudo systemctl set-default multi-user && echo You need to reboot the system"
          alias setGUI="sudo systemctl set-default graphical && echo You need to reboot the system"
        fi
        ;;
      Arch)
        alias update="sudo pacman -Syu"
        ;;
      *);;
    esac
    ;;
  Mac)
    alias ls="ls -lhG"
    alias projects='cd /Volumes/Projects'
    ;;
  *);;
esac

#==============================================================================
# FUNCTIONS
#==============================================================================

function piKVM {
  kvm=
  if [[ $1 != "" ]]; then kvm=$1; fi
  if [[ "${kvm}" == "" ]]; then echo "KVM IP?"; read kvm; fi
  echo "Connecting to ${kvm}"
  case $OS in
    Linux)
      `which chromium 2>/dev/null || which chrome 2>/dev/null || which google-chrome` --app="https://${kvm}/"
      ;;
    Mac)
      /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app="https://${kvm}/"
      ;;
    Windows)
      C:\> start chrome --app="https://${kvm}/"
      ;;
  esac
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
  pkg nmap
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
  pkg nmap
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

if [[ "$OS" == "Mac" ]]; then
  function restoreDMG {
    pkg pv
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
    pkg pv
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

  function trans {
    if [[ ! -f "/Users/${USER}/bin/trans" ]]; then
      mkdir -p "/Users/${USER}/bin/"
      cd "/Users/${USER}/bin/"
      wget https://raw.githubusercontent.com/soimort/translate-shell/gh-pages/trans
      chmod +x trans
    fi
    if [[ $1 != "" ]]; then
      file=$1
      if [[ $2 != "" ]]; then
        lang=$2
      else
        lang=en
      fi
      if [[ -f "${file}" ]]; then
        for line in $(cat ${file}); do
          bash /Users/${USER}/bin/trans -b :${lang} "${line}"
        done
      else
        bash /Users/${USER}/bin/trans -b :${lang} "${file}"
      fi
    fi
  }
fi

#==============================================================================
# PROFILE
#==============================================================================

# SETS LOCALE to en_US
export LC_ALL=en_US.UTF-8 > /dev/null 2>&1 || export LC_ALL=en_GB.UTF-8 > /dev/null 2>&1 || export LC_ALL=C.UTF-8 > /dev/null 2>&1

# Configure Editor
case $OS in
  Linux)
    export EDITOR=/usr/bin/nano
    ;;
  Mac)
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export EDITOR=nano
    export VISUAL="$EDITOR"
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
    ;;
  *);;
esac

# Enable color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
if [[ $- == *i* ]]; then format; else clrformat; fi

# Enable elements
elements

#==============================================================================
# Prompt
#==============================================================================

if [[ ${EUID} == 0 ]]; then
  pUSER="[${lightredText}\u${lightyellowText}@${lightblueText}\h${resetText}]"
else
  pUSER="[${lightblueText}\u${lightgreenText}@${lightblueText}\h${resetText}]"
fi
pIP="[${redText}${IP}${resetText}]"
pCWD="[${lightcyanText}\w${resetText}]"
if [ "$(type -t __git_ps1)" = 'function' ]; then
  pGIT='$(__git_ps1 "${frameHline}[${lightgreenText}%s${resetText}]")'
else
  pGIT=
fi
PS1="${frameTopLeft}${frameHline}${pUSER}${frameHline}${pIP}${frameHline}${pCWD}${pGIT}"
PS1="${PS1}\n${frameBottomLeft}${frameHline}${frameHline}${frameHlineEnd} $ "

#==============================================================================
# Greetings
#==============================================================================

if [[ $- == *i* ]]; then
  if [[ "$PackageManager" != "" ]]; then
    if [[ "$OS" == "Linux" ]]; then
      linuxlogo -u -y -b
    fi
    if [[ ${EUID} == 0 ]]; then
      echo
      toilet -f smblock --filter border -w 120 ' Careful!   You are now root! '
    fi
  fi
  echo
  echo -ne "Good Morning, $USER! It's "; date '+%A, %B %-d %Y'
  echo
fi

#==============================================================================
# Loading custom settings
#==============================================================================

if [ -x ~/.profile ]; then source ~/.profile; fi
if [ -x ~/.bash_aliases ]; then source ~/.bash_aliases; fi
