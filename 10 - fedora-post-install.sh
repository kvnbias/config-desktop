
#!/bin/bash

if [ "$1" = "" ];then
  fedver=$(rpm -E %fedora)
else
  fedver=$1
fi

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

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
sudo dnf -y upgrade

sudo dnf install -y kernel-devel kernel-headers --releasever=$fedver
sudo dnf install -y gcc make dkms pkgconfig bzip2 --releasever=$fedver

# Activate numlock on boot
sudo dnf install -y numlockx --releasever=$fedver

# Create user dirs
sudo dnf install -y xdg-user-dirs --releasever=$fedver

if [ ! -d "/home/$(whoami)/Desktop" ];then
  xdg-user-dirs-update
fi

# Hibernation
if dnf list installed | grep -q grub2; then
  if sudo cat /etc/default/grub | grep -q 'resume='; then
    echo "Hibernation already enabled..."
  else
    if [ -f /etc/default/grub ]; then
      while true; do
        read -p "

Do you like to enable hibernation [Yn]?   " yn
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
          * )
            while true; do
              read -p "Using UEFI [Yn]?   " yn
              case $yn in
                [Nn]* )
                  sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
                  break 2;;
                * )
                  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
                  break 2;;
              esac
            done
            break;;
        esac
      done
    else
      echo No GRUB config
    fi
  fi
fi

sudo dnf install -y acpid --releasever=$fedver

sudo systemctl enable acpid

# utils: lspci + lsusb
sudo dnf install -y pciutils usbutils --releasever=$fedver


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
