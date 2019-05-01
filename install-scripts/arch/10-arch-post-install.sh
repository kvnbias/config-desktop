#!/bin/bash
# NOTE this script is only tested in my machines

if [ -f /arch-install ]; then
  sudo rm /arch-install
fi

while true; do
  read -p "Will boot with other linux distros and share a partitions [yN]?   " wdb
  case $wdb in
    [Yy]* )
      while true; do
        echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
        read -p "Enter UID or [e]xit:   " uid
        case $uid in
          [Ee]* ) break;;
          * )
            while true; do
              echo "

NOTE: Use a GUID that will less likely be used as an ID by other distros (e.g. 1106).
This GUID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2 (Ctrl + Alt + F2):

groupadd wheel
usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Choose action: [l]ogout | [s]kip   " wultp
                    case $wultp in
                      [Ss]* ) break 4;;
                      [Ll]* ) sudo pkill -KILL -u $(whoami);;
                      * ) echo "Invalid input";;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    * ) break;;
  esac
done

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

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ -d /sys/firmware/efi/efivars ]; then
  sudo mkdir -p /boot/efi/EFI/BOOT
  if [ ! -f "/boot/efi/startup.nsh" ]; then
    if [ -d "/boot/efi/EFI/BOOT" ]; then
      if [ -d "/boot/efi/EFI/refind" ]; then
        sudo cp -a /boot/efi/EFI/refind/refind_x64.efi /boot/efi/EFI/BOOT/bootx64.efi
      elif [ -d "/boot/efi/EFI/grub" ]; then
        sudo cp -a /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
      elif [ -d "/boot/efi/EFI/GRUB" ]; then
        sudo cp -a /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
      else
        sudo cp -a /boot/efi/EFI/$os/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
      fi
    fi

    echo "bcf boot add 1 fs0:\\EFI\\BOOT\\bootx64.efi \"Fallback Bootloader\"
exit" | sudo tee /boot/efi/startup.nsh
  fi
fi

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

if [ -f /etc/default/grub ]; then
  sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub

  if cat /etc/default/grub | grep -q 'GRUB_SAVEDEFAULT'; then
    sudo sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/g' /etc/default/grub
  else
    echo 'GRUB_SAVEDEFAULT="true"' | sudo tee -a /etc/default/grub
  fi

  if sudo cat /etc/default/grub | grep -q 'resume='; then
    echo "Hibernation already enabled..."
  else
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

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * )
          sudo mkinitcpio -P;
          sudo grub-mkconfig -o /boot/grub/grub.cfg;
          break;;
      esac
    done;
  fi
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
