#!/bin/bash
# NOTE this script is only tested in my machines

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/debian-sudo-prompt.sh "$os"
bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

if [ "$os" = "debian" ]; then
  if cat /etc/apt/sources.list | grep -q "main contrib non-free"; then
    echo "Non-free repos already added."
  else
    sudo sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
    echo "Non-free repos added."
  fi
fi

sudo apt -y upgrade
sudo apt update

sudo apt install -y build-essential linux-headers-$(uname -r)
sudo apt install -y --no-install-recommends numlockx
sudo apt install -y --no-install-recommends xdg-user-dirs

if [ ! -d "$HOME/Desktop" ];then
  xdg-user-dirs-update
fi

bash $DIR/../../setup-scripts/hibernation-prompt.sh "" "grub"

sudo apt install -y --no-install-recommends acpid
sudo systemctl enable acpid

sudo apt install -y --no-install-recommends pciutils usbutils

echo '

####################################
####################################
###                              ###
###    INSTALLATION COMPLETE     ###
###    BETTER INSTALL DISPLAY    ###
###    SERVERS NOW ...           ###
###                              ###
####################################
####################################

'

