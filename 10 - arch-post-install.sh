#!/bin/bash
# NOTE this script is only tested in my machines

sudo rm /arch-install

# https://www.archlinux.org/groups/x86_64/base-devel/
# Current libs (3/15/2019)
# autoconf    automake     binutils    bison      fakeroot
# file        findutils    flex        gawk       gcc
# gettext     grep         groff       gzip       libtool
# m4          make         pacman      patch      pkgconf
# sed         sudo         systemd     texinfo    util-linux
# which
yes | sudo pacman -S base-devel --noconfirm

isManjaro=false
while true; do
  read -p "Using manjaro [yN]?   " p
  case $p in
    [Yy]* )
      isManjaro=true;
      break;;
    * ) break;;
  esac
done

if [ "$isManjaro" = true ]; then
  major=$(uname -r | cut -f 1 -d .);
  minor=$(uname -r | cut -f 2 -d .);
  version=$(echo $major$minor);
  yes | sudo pacman -S linux$version linux$version-headers;
else
  while true; do
    read -p "

Install LTS kernel? [y]es | [n]o   " ilts
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
fi

if [ -f /etc/default/grub ]; then
  sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
  sudo sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/g' /etc/default/grub
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

# install AUR helper: yay
git clone https://aur.archlinux.org/yay.git
cd yay
yes | makepkg --syncdeps --install
yes | yay -Syu
cd ..
rm -rf yay

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

# Hibernation
while true; do
  read -p "Do you like to enable hibernation [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        sudo fdisk -l;
        read -p "What device to use (e.g. /dev/sdXn) or [e]xit   ?   " dvc
        case $dvc in
          [Ee]* ) break;;
          * )
            sudo sed -i "s~GRUB_CMDLINE_LINUX_DEFAULT=\"~GRUB_CMDLINE_LINUX_DEFAULT=\"resume=$dvc ~g" /etc/default/grub
            break 2;;
        esac
      done;;
  esac
done

if [ -f /etc/default/grub ]; then
  while true; do
    read -p "Update GRUB [Yn]?   " updgr
    case $updgr in
      [Nn]* )
        break;;
      * )
        sudo mkinitcpio -P;
        sudo grub-mkconfig -o /boot/grub/grub.cfg;
        break;;
    esac
  done;
fi

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
