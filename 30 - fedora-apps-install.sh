
#!/bin/bash

mainCWD=$(pwd)

os=$(echo -n $(sudo cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

sudo dnf -y upgrade

sudo dnf install -y curl vim-enhanced wget httpie git tmux gedit --releasever=$fedver
sudo dnf install -y lsof bash-completion gamin polkit-gnome --releasever=$fedver

# exfat readable
sudo dnf install -y exfat-utils fuse-exfat ntfs-3g --releasever=$fedver

# media
sudo dnf install -y eog totem --releasever=$fedver

# firefox
sudo dnf install -y firefox --releasever=$fedver

# extra
sudo dnf install -y libreoffice vlc transmission-gtk mupdf xarchiver p7zip --releasever=$fedver

while true; do
  read -p "

Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* )
      sudo dnf install -y simplescreenrecorder --releasever=$fedver
      break;;
    * ) break;;
  esac
done

# No choice.
# while true; do
#   read -p "
#
# Install JDownloader [yN]?  " ijd
#   case $isr in
#     [Yy]* )
#       sudo dnf install -y flatpak --releasever=$fedver
#       sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#       flatpak install -y flathub org.jdownloader.JDownloader
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      sudo dnf install -y timeshift --releasever=$fedver
      break;;
    * ) break;;
  esac
done

# guest addition iso location:
# /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
#
# on VM after mounting:
# $ lsblk
#     sr0    11:0    1    75.6M    0    rom
# $ sudo mount /dev/sr0 /mnt
# $ sudo /mnt/VBoxLinuxAdditions.run
while true; do
  read -p "

Install virtualbox [yN]?
https://wiki.archlinux.org/index.php/VirtualBox   " ivb
  case $ivb in
    [Yy]* )
      sudo dnf install -y gcc make perl --releasever=$fedver
      sudo dnf install -y VirtualBox virtualbox-guest-additions --releasever=$fedver
      sudo dnf install -y akmod-VirtualBox kmod-VirtualBox --releasever=$fedver
      sudo dracut -v -f
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install firewall [yN]?
https://wiki.archlinux.org/index.php/Uncomplicated_Firewall   " ifw
  case $ifw in
    [Yy]* )
      sudo dnf install -y ufw --releasever=$fedver
      sudo systemctl enable ufw
      sudo systemctl start ufw
      sudo ufw enable
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install bluetooth [yN]?
https://wiki.archlinux.org/index.php/bluetooth   " ibt
  case $ibt in
    [Yy]* )
      sudo dnf install -y bluez blueman pulseaudio-module-bluetooth --releasever=$fedver

      echo "
load-module module-bluetooth-policy
load-module module-bluetooth-discover
" | sudo tee -a /etc/pulse/system.pa

      sed -i "s/# exec --no-startup-id blueman-applet/exec --no-startup-id blueman-applet/g" $HOME/.config/i3/config
      sed -i "s/# for_window \[class=\"Blueman-manager\"\]/for_window \[class=\"Blueman-manager\"\]/g" $HOME/.config/i3/config

      sudo systemctl enable bluetooth
      sudo systemctl start bluetooth
      break;;
    * ) break;;
  esac
done

# For windows, go to appwiz.cpl, turn on the windows feature "SMB CIFS File Sharing Support"
while true; do
  read -p "

Install Samba [yN]?
https://wiki.archlinux.org/index.php/Samba   " ismb
  case $ismb in
    [Yy]* )
      user=$(whoami)
      sudo dnf install -y samba --releasever=$fedver

      mkdir -p "/home/$user/Share"
      sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bup
      echo "

[global]
    # workgroup = NT-Domain-Name or Workgroup-Name, eg: MIDEARTH
    #
    # Default windows 10 workgroup
    workgroup = WORKGROUP

    # Server role. Defines in which mode Samba will operate. Possible
    # values are 'standalone server', 'member server', 'classic primary
    # domain controller', 'classic backup domain controller', 'active
    # directory domain controller'.
    #
    # Most people will want 'standalone server' or 'member server'.
    # Running as 'active directory domain controller' will require first
    # running 'samba-tool domain provision' to wipe databases and create a
    # new domain.
    server role = standalone server

    # server string is the equivalent of the NT Description field
    server string = $user's Samba Server

    # Failed login or anonymous user will be a guest user.
    map to guest = bad user

    # This option is important for security. It allows you to restrict
    # connections to machines which are on your local network. The
    # following example restricts access to two C class networks and
    # the 'loopback' interface. For more examples of the syntax see
    # the smb.conf man page
    hosts allow = 192.168.1. 192.168.2. 127.

[$user]
    comment = $user's shared folder

    # Directory to share
    path = /home/$user/Share

    # Makes share folder writeable
    read only = no
    writeable = yes

    # Anybody who access is a guest
    guest ok = yes

    # Force written file will be named after $user
    force user = $user

    # Force written file will be in group wheel
    force group = wheel

[printers]
    comment = All Printers
    path = /usr/spool/samba
    browseable = no
    guest ok = no
    writable = no
    printable = yes
" | sudo tee /etc/samba/smb.conf

      if [ -d /etc/ufw/applications.d ]; then
        echo "
[Samba]
title=Samba
description=Samba Server
ports=137:138/udp|139/tcp|445/tcp
" | sudo tee /etc/ufw/applications.d/ufw-samba

        sudo ufw allow Samba
      fi

      sudo systemctl enable smb
      sudo systemctl restart smb
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install CUPS [yN]?
https://wiki.archlinux.org/index.php/CUPS   " ic
  case $ic in
    [Yy]* )
      sudo dnf install -y cups bluez-cups cups-pdf nss-mdns --releasever=$fedver

      sudo systemctl enable avahi-daemon
      sudo systemctl restart avahi-daemon

      sudo systemctl enable cups
      sudo systemctl start cups
      break;;
    * ) break;;
  esac
done

# while true; do
#   read -p "
#
# Will mount HFS+ partitions [yN]?   " mfsp
#   case $mfsp in
#     [Yy]* )
#       # To mount HFS+
#       # 1. Repair: sudo fsck.hfsplus -f /dev/sda2
#       # 2. Mount: sudo mount -t hfsplus -o force,rw /dev/sda2 /mnt
#       sudo dnf install -y hfsplusutils hfsutils hfsplus-tools --releasever=$fedver
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Will mount APFS partitions [yN]?
https://github.com/sgan81/apfs-fuse   " mapfs
  case $mapfs in
    [Yy]* )
      cd /tmp
      sudo dnf install -y fuse zlib bzip2 libattr --releasever=$fedver
      sudo dnf install -y fuse-devel zlib-devel bzip2-devel libattr-devel --releasever=$fedver
      sudo dnf install -y cmake gcc-c++ git --releasever=$fedver

      git clone https://github.com/sgan81/apfs-fuse.git
      cd apfs-fuse && git submodule init && git submodule update
      rm -rf build && mkdir build && cd build && cmake .. && make
      sudo cp -raf  ./apfs-* /usr/local/bin/

      sudo dnf remove -y fuse-devel bzip2-devel libattr-devel cmake
      cd /tmp
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install OS-Prober [yN]?
https://wiki.archlinux.org/index.php/GRUB#Detecting_other_operating_systems
   " iop
  case $iop in
    [Yy]* )
      sudo dnf install -y os-prober --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install rEFInd [yN]?

While rEFInd can boot any OS/Distro, the auto-detect feature may have problems
booting a distro that have multiple kernels installed.

https://wiki.archlinux.org/index.php/REFInd
   " ir
  case $ir in
    [Yy]* )
      while true; do
        read -p "

Would you like to rice rEFInd [yN]?   " rr
        case $rr in
          [Yy]* )
            cd /tmp
            wget -O "refind-bin-0.11.4.zip" "http://sourceforge.net/projects/refind/files/0.11.4/refind-bin-0.11.4.zip/download"
            unzip refind-bin-0.11.4.zip && unzip refind-bin-0.11.4.zip && sudo bash refind-bin-0.11.4/refind-install

            git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git /tmp/refind-minimal
            sudo mkdir -p /boot/efi/EFI/refind/themes/rEFInd-minimal
            sudo cp -raf --no-preserve=mode,ownership /tmp/refind-minimal/* /boot/efi/EFI/refind/themes/rEFInd-minimal
            echo "include themes/refind-minimal/theme.conf" | sudo tee -a /boot/efi/EFI/refind/refind.conf

            cd /tmp

            echo '

#####################################
#####################################
###                               ###
###    INSTALLATION COMPLETE      ###
###                               ###
###    rEFInd has been set as     ###
###    your primary bootloader    ###
###                               ###
###    change bootloader order    ###
###    priority in `efibootmgr    ###
###                               ###
#####################################
#####################################

'
            break 2;;
          * )
            cd /tmp
            wget -O "refind-bin-0.11.4.zip" "http://sourceforge.net/projects/refind/files/0.11.4/refind-bin-0.11.4.zip/download"
            unzip refind-bin-0.11.4.zip && unzip refind-bin-0.11.4.zip && sudo bash refind-bin-0.11.4/refind-install
            cd /tmp

            echo '

#####################################
#####################################
###                               ###
###    INSTALLATION COMPLETE      ###
###                               ###
###    rEFInd has been set as     ###
###    your primary bootloader    ###
###                               ###
###    change bootloader order    ###
###    priority in `efibootmgr    ###
###                               ###
#####################################
#####################################

'
        break 2;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Skype [yN]?   " is
  case $is in
    [Yy]* )
      sudo dnf install -y gnome-keyring --releasever=$fedver
      cd /tmp
      wget -O "skypeforlinux-64.rpm" "https://go.skype.com/skypeforlinux-64.rpm"
      sudo dnf install -y skypeforlinux-64.rpm
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* )
      sudo dnf install -y gimp --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* )
      sudo dnf install -y geary --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo dnf install -y gnome-calendar --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo dnf install -y gnome-calculator --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GParted [yN]?   " igp
  case $igp in
    [Yy]* )
      sudo dnf install -y gparted --releasever=$fedver
      break;;
    * ) break;;
  esac
done

cd $mainCWD
sudo dnf autoremove
