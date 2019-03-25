
#!/bin/bash

# update all
sudo pacman -Syu

yes | sudo pacman -S curl wget vim httpie git tmux gedit
yes | sudo pacman -S lsof bash-completion gamin polkit-gnome
yes | yay -S downgrade
# yes | yay -S gksu --noconfirm

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
yes | sudo pacman -S exfat-utils fuse-exfat ntfs-3g

# media
yes | sudo pacman -S eog

# firefox
yes | sudo pacman -S firefox

# extra
yes | sudo pacman -S libreoffice-fresh vlc
yes | sudo pacman -S transmission-gtk --noconfirm

# extra
yes | sudo pacman -S evince xarchiver p7zip

while true; do
  read -p "

Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* )
      yes | sudo pacman -S simplescreenrecorder 
      break;;
    * ) break;;
  esac
done

# while true; do
#   read -p "
#
# Install JDownloader [yN]?  " ijd
#   case $isr in
#     [Yy]* )
#       yes | yay -S jdownloader2 
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      yes | yay -S timeshift
      sudo systemctl enable cronie
      sudo systemctl start cronie
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
      yes | sudo pacman -S gcc make perl
      yes | sudo pacman -S virtualbox-host-dkms
      yes | sudo pacman -S virtualbox
      yes | sudo pacman -S virtualbox-guest-iso
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install openssh [yN]?
This will remove OpenSSH SELinux
https://wiki.archlinux.org/index.php/OpenSSH   " ios
  case $ios in
    [Yy]* )
     yes | sudo pacman -S openssh
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
      yes | sudo pacman -S ufw gufw
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
      yes | sudo pacman -S bluez bluez-utils blueman pulseaudio-bluetooth

      echo "
load-module module-bluetooth-policy
load-module module-bluetooth-discover
" | sudo tee -a /etc/pulse/system.pa

      sed -i 's/# exec --no-startup-id blueman-applet/exec --no-startup-id blueman-applet/g' $HOME/.config/i3/config
      sed -i 's/# for_window [class="Blueman-manager"] floating enable normal/for_window [class="Blueman-manager"] floating enable normal/g' $HOME/.config/i3/config

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
      yes | sudo pacman -S samba

      mkdir -p "/home/$user/Share"

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
      yes | sudo pacman -S cups bluez-cups cups-pdf nss-mdns

      if ! cat /etc/nsswitch.conf | grep -q "\[NOTFOUND=return\] resolve"; then
        sudo sed -i "s/resolve/mdns4_minimal [NOTFOUND=return] resolve/g" /etc/nsswitch.conf
      fi

      sudo systemctl enable avahi-daemon
      sudo systemctl restart avahi-daemon

      sudo systemctl enable org.cups.cupsd
      sudo systemctl start org.cups.cupsd
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
#       yes | yay -S hfsprogs
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
      yes | yay -S apfs-fuse-git
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
      yes | sudo pacman -S os-prober
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
            yes | sudo pacman -S refind-efi
            refind-install

            git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git /tmp/refind-minimal
            sudo mkdir -p /boot/efi/EFI/refind/themes/rEFInd-minimal
            sudo cp -raf --no-preserve=mode,ownership /tmp/refind-minimal/* /boot/efi/EFI/refind/themes/rEFInd-minimal
            echo "include themes/refind-minimal/theme.conf" | sudo tee -a /boot/efi/EFI/refind/refind.conf

            cd $cwd

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
            yes | sudo pacman -S refind-efi
            refind-install

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
      yes | sudo pacman -S gnome-keyring
      yes | yay -S skypeforlinux-stable-bin
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* )
      yes | sudo pacman -S gimp
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* )
      yes | sudo pacman -S geary
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

NOTE: Currently tightly coupled in arch.
Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* )
      # Currently tightly coupled with evolution and cheese:
      # yes | sudo pacman -S gnome-calendar
      # tightly coupled with cheese
      # yes | yay -S gnome-calendar-no-evolution
      yes | yay -S gnome-calendar-linuxmint
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* )
      yes | sudo pacman -S gnome-calculator
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GParted [yN]?   " igp
  case $igp in
    [Yy]* )
      yes | sudo pacman -S gparted
      break;;
    * ) break;;
  esac
done

