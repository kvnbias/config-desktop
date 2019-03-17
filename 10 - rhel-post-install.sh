
#!/bin/bash
# NOTE this script is only tested in my machines

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
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

if [ "$os" = "fedora" ]; then
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
else
  sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
fi

sudo dnf -y upgrade

sudo dnf install -y kernel-devel kernel-headers --releasever=$fedver
sudo dnf install -y gcc gcc-c++ autoconf automake cmake make dkms pkgconfig bzip2 --releasever=$fedver

# Activate numlock on boot
sudo dnf install -y numlockx --releasever=$fedver

# Create user dirs
sudo dnf install -y xdg-user-dirs --releasever=$fedver

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
                sudo dracut -v -f
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
          done;;
      esac
    done
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
