

#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo zypper -n update

sudo zypper -n install --no-recommends curl vim wget python3-httpie git tmux gedit
sudo zypper -n install --no-recommends lsof bash-completion polkit-gnome

while true; do
  read -p "Enable vi mode on bash [yN]?   " ebvi
  case $ebvi in
    [Yy]* )
      if cat $HOME/.bashrc | grep -q 'set -o vi'; then
        sed -i 's/# set -o vi/set -o vi/g' $HOME/.bashrc
      else
        echo 'set -o vi' | tee -a $HOME/.bashrc
      fi

      break;;
    *) break;;
  esac
done

# exfat readable
sudo zypper -n install --no-recommends exfat-utils fuse-exfat ntfs-3g

# media
sudo zypper -n install --no-recommends eog

# firefox
sudo zypper -n install --no-recommends MozillaFirefox MozillaFirefox-branding-openSUSE

# extra
sudo zypper -n install --no-recommends libreoffice libreoffice-gtk3 libreoffice-base
sudo zypper -n install --no-recommends libreoffice-writer libreoffice-math libreoffice-draw libreoffice-calc
sudo zypper -n install --no-recommends vlc transmission-gtk mupdf p7zip evince

while true; do
  read -p "

Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* )
      sudo zypper -n install --no-recommends simplescreenrecorder
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
#       sudo zypper -n install --no-recommends flatpak
#       sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#       flatpak -n install --no-recommends flathub org.jdownloader.JDownloader
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      wget -O /tmp/timeshift-v19.01-amd64.run https://github.com/teejee2008/timeshift/releases/download/v19.01/timeshift-v19.01-amd64.run
      sudo zypper -n install --no-recommends libgee-0_8-2 libvte-2_91-0 libjson-glib-1_0-0 rsync
      sudo sh /tmp/timeshift-v19.01-amd64.run
      echo "Timeshift has been installed"
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
      sudo zypper -n install --no-recommends virtualbox virtualbox-qt
      sudo zypper -n install --no-recommends virtualbox-host-source kernel-devel kernel-default-devel
      sudo usermod -aG vboxusers $(whoami)
      sudo /usr/lib/virtualbox/vboxdrv.sh setup
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
      sudo zypper -n install --no-recommends ufw
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
      sudo zypper -n install --no-recommends bluez bluez-auto-enable-devices blueman pulseaudio-module-bluetooth

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
      sudo zypper -n install --no-recommends samba samba-client samba-libs

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
      sudo zypper -n install --no-recommends cups cups-client cups-config bluez-cups cups-pdf nss-mdns

      sudo systemctl enable avahi-daemon
      sudo systemctl restart avahi-daemon

      sudo systemctl enable cups
      sudo systemctl start cups
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Will mount APFS partitions [yN]?
https://github.com/sgan81/apfs-fuse   " mapfs
  case $mapfs in
    [Yy]* )
      cd /tmp
      sudo zypper -n install --no-recommends fuse libz1 bzip2 libattr1
      sudo zypper -n install --no-recommends fuse-devel zlib-devel libbz2-devel libattr-devel
      sudo zypper -n install --no-recommends cmake gcc-c++ git

      git clone https://github.com/sgan81/apfs-fuse.git
      cd apfs-fuse && git submodule init && git submodule update
      rm -rf build && mkdir build && cd build && cmake .. && make
      sudo cp -raf  ./apfs-* /usr/local/bin/

      sudo zypper -n remove fuse-devel libbz2-devel libattr-devel cmake
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
      sudo zypper -n install --no-recommends os-prober
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
      sudo zypper -n install --no-recommends gnome-keyring
      sudo zypper ar -f https://repo.skype.com/rpm/stable skype
      sudo zypper update
      sudo zypper -n install --no-recommends gconf2 gconf-polkit skypeforlinux
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* )
      sudo zypper -n install --no-recommends gimp
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* )
      sudo zypper -n install --no-recommends geary
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo zypper -n install --no-recommends gnome-calendar
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo zypper -n install --no-recommends gnome-calculator
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GParted [yN]?   " igp
  case $igp in
    [Yy]* )
      sudo zypper -n install --no-recommends gparted
      break;;
    * ) break;;
  esac
done

sudo zypper remove -u $(zypper packages --unneeded | grep -v '+-' | grep -v '\.\.\.' | grep -v 'Version' | cut -f 3 -d '|')
