#!/bin/bash
# NOTE this script is only tested in my machines

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))
user=$(whoami)

while true; do
  read -p "
If sudo is not enabled during installation (Debian). Login as root on tty2 (Ctrl + Alt + F2)
then execute the commands below before proceeding.

apt install -y sudo libuser
groupadd wheel
usermod -aG wheel $user
usermod -aG sudo $user
usermod -g wheel $user
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers

Changes will reflect on the next login. Proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) echo "";;
    * ) break;;
  esac
done

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

## Start swap initialization
while true; do
  lsblk
  read -p "Initialize swap partition. If not mounted [yN]   " yn
  case $yn in
    [Yy]* )
      while true; do
        sudo fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * ) sudo mkswap $td;sudo swapon $td; break;;
        esac
      done;;
    * ) break;;
  esac
done

sudo apt install -y --no-install-recommends numlockx
sudo apt install -y --no-install-recommends xdg-user-dirs

if [ ! -d "/home/$(whoami)/Desktop" ];then
  xdg-user-dirs-update
fi

# Hibernation
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
                sudo sed -i "s~GRUB_CMDLINE_LINUX=\"~GRUB_CMDLINE_LINUX=\"resume=$dvc ~g" /etc/default/grub
                break 2;;
            esac
        done;;
      esac
    done

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
fi

sudo apt install -y --no-install-recommends acpid
sudo systemctl enable acpid

sudo apt install -y --no-install-recommends pciutils usbutils

sudo chown -R $user:wheel /home/$user

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

