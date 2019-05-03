
#!/bin/bash
# NOTE this script is only tested in my machines

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

if [ "$os" = "fedora" ]; then
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
else
  sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
fi

sudo dnf -y upgrade
echo 'metadata_expire=86400' | sudo tee -a /etc/dnf/dnf.conf

sudo dnf install -y kernel-devel kernel-headers --releasever=$fedver
sudo dnf install -y gcc gcc-c++ autoconf automake cmake make dkms pkgconfig bzip2 --releasever=$fedver

# Activate numlock on boot
sudo dnf install -y numlockx --releasever=$fedver

# Create user dirs
sudo dnf install -y xdg-user-dirs --releasever=$fedver

if [ ! -d "/home/$(whoami)/Desktop" ];then
  xdg-user-dirs-update
fi

if cat /etc/default/grub | grep -q "GRUB_CMDLINE_LINUX=\".*rhgb.*\""; then
  sudo sed -i "s/rhgb//g" /etc/default/grub
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

bash $DIR/../../setup-scripts/hibernation-prompt.sh "sudo dracut -v -f" "grub2"

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
