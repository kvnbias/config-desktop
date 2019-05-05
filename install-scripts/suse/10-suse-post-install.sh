
#!/bin/bash
# NOTE this script is only tested in my machines

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

sudo zypper refresh
sudo zypper -n update

sudo zypper -n install --no-recommends kernel-devel
sudo zypper -n install --no-recommends numlockx xdg-user-dirs

if [ ! -d "$HOME/Desktop" ];then
  xdg-user-dirs-update
fi

bash $DIR/../../setup-scripts/hibernation-prompt.sh "" "grub2"

sudo zypper -n install --no-recommends acpid
sudo systemctl enable acpid

sudo zypper -n install --no-recommends pciutils usbutils

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
