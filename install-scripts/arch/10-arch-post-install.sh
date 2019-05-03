#!/bin/bash
# NOTE this script is only tested in my machines

if [ -f /arch-install ]; then
  sudo rm /arch-install
fi

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

# https://www.archlinux.org/groups/x86_64/base-devel/
# Current libs (3/15/2019)
# autoconf    automake     binutils    bison      fakeroot
# file        findutils    flex        gawk       gcc
# gettext     grep         groff       gzip       libtool
# m4          make         pacman      patch      pkgconf
# sed         sudo         systemd     texinfo    util-linux
# which
while true; do
  read -p "This package might installed during installation. Install base-devel [yN]?   " p
  case $p in
    [Yy]* )
      yes | sudo pacman -S base-devel --noconfirm
      break;;
    * ) break;;
  esac
done

if [ "$os" != "manjaro" ]; then
  while true; do
    read -p "Install LTS kernel? [y]es | [n]o   " ilts
    case $ilts in
      [Yy]* )
        yes | sudo pacman -S linux-lts linux-lts-headers
        break;;
      [Nn]* )
        yes | sudo pacman -S linux linux-headers
        break;;
      * ) echo Invalid input
    esac
  done;
else
  major=$(uname -r | cut -f 1 -d .);
  minor=$(uname -r | cut -f 2 -d .);
  version=$(echo $major$minor);
  yes | sudo pacman -S linux$version linux$version-headers;
fi

while true; do
  read -p "Would you like to increase AUR threads [Yn]?   " aurt
  case $aurt in
    [Nn]* ) break;;
    * )
      while true; do
        read -p "How many threads you would like to add or [e]xit   " numt
        case $numt in
          [Ee]* ) break;;
          * )
            if [[ $numt =~ ^[0-9]+$ ]]; then
              sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$numt\"/g" /etc/makepkg.conf;
              echo Threads increased to $numt;
              break;
            else
              echo Invalid input;
              break;
            fi
        esac
      done;;
  esac
done

# Remove orphan packages from yay
yes | sudo pacman -Rns $(pacman -Qtdq)

## Enabling multilib
# Contains 32-bit software and libraries that can be
# used to run and build 32-bit applications on 64-bit installs (e.g. wine, steam, etc). 
sudo sed -i ":a;N;\$!ba;s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/g" /etc/pacman.conf;
sudo pacman -Sy

# Activate numlock on boot
yes | sudo pacman -S numlockx

# Create user dirs
yes | sudo pacman -S xdg-user-dirs
xdg-user-dirs-update

bash $DIR/../../setup-scripts/hibernation-prompt.sh "sudo mkinitcpio -P" "grub"

yes | sudo pacman -S acpid

sudo systemctl enable acpid

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
