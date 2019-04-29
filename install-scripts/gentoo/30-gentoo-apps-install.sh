
#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if cat /etc/portage/make.conf | grep -q 'USE='; then
  if ! cat /etc/portage/make.conf | grep -q 'udisks'; then
    sudo sed -i "s/USE=\"/USE=\"udisks /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'alsa pulseaudio'; then
    sudo sed -i "s/USE=\"/USE=\"alsa pulseaudio /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'gtk gtk3'; then
    sudo sed -i "s/USE=\"/USE=\"gtk gtk3 /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'jpeg jpeg2k jpg png truetype'; then
    sudo sed -i "s/USE=\"/USE=\"jpeg jpeg2k jpg png truetype /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'ffmpeg'; then
    sudo sed -i "s/USE=\"/USE=\"ffmpeg -libav /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'systemd'; then
    sudo sed -i "s/USE=\"/USE=\"systemd /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'X'; then
    sudo sed -i "s/USE=\"/USE=\"X /g" /etc/portage/make.conf
  fi
else
  echo "USE=\"X systemd alsa pulseaudio udisks ffmpeg -libav gtk gtk3 jpeg jpeg2k jpg png truetype\"" | sudo tee -a /etc/portage/make.conf
fi

install_packages() {
  while true; do
    read -p "
NOTE: Sometimes you need to merge the configs before the packages get installed

Target: $1

[1] Install
[2] Sync
[3] Update world
[4] Auto merge configs
[5] Execute command
[6] Exit

Action:   " ipa
    case $ipa in
      1 ) sudo emerge --ask $1;;
      2 ) sudo emerge --sync;;
      3 ) sudo emerge --ask --verbose --update --deep --newuse @world;;
      4 ) yes | sudo etc-update --automode -3;;
      5 )
        while true; do
          read -p "Command to execute or [e]xit:   " cmd
          case $cmd in
            [Ee] ) break;;
            * ) $cmd;;
          esac
        done;;
      6 ) break;;
    esac
  done
}

add_ebuild() {
  sudo mkdir -p /usr/local/portage/$1/$2
  sudo cp $3 /usr/local/portage/$1/$2/
  sudo chown -R portage:portage /usr/local/portage
  pushd /usr/local/portage/$1/$2
  sudo repoman manifest
  popd
}

sudo touch /etc/portage/package.use/flags
if ! sudo cat /etc/portage/package.use/flags | grep -q 'sys-auth/polkit gtk'; then
  echo 'sys-auth/polkit gtk' | sudo tee -a /etc/portage/package.use/flags
fi

install_packages "net-misc/curl net-misc/wget net-misc/httpie sys-process/lsof dev-vcs/git app-misc/tmux app-editors/vim app-editors/gedit"
install_packages "app-shells/bash-completion app-admin/gamin gnome-extra/polkit-gnome"

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

# external drives readable
install_packages "sys-fs/exfat-utils sys-fs/fuse-exfat sys-fs/ntfs3g"
install_packages "media-gfx/eog www-client/firefox-bin app-office/libreoffice-bin"

if ! sudo cat /etc/portage/package.use/flags | grep -q 'media-video/vlc'; then
  echo "media-video/vlc gstreamer libass matroska faad flac mp3 mpeg ogg v4l vaapi vdpau x264" | sudo tee -a /etc/portage/package.use/flags
fi

if ! sudo cat /etc/portage/package.use/flags | grep -q 'app-arch/p7zip'; then
  echo "app-arch/p7zip rar" | sudo tee -a /etc/portage/package.use/flags
fi

install_packages "media-video/vlc net-p2p/transmission app-text/mupdf app-arch/xarchiver app-arch/p7zip app-text/evince"

while true; do
  read -p "

Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'media-video/simplescreenrecorder'; then
        echo "media-video/simplescreenrecorder mp3 x264" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "media-video/simplescreenrecorder"
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
#       install_packages "flatpak"
#       sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#       flatpak install -yflathub org.jdownloader.JDownloader
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      # MANUAL: timeshift 19.01
      # install_packages "dev-libs/libgee dev-libs/json-glib net-misc/rsync x11-libs/vte"
      # wget -O /tmp/timeshift-v19.01-amd64.run https://github.com/teejee2008/timeshift/releases/download/v19.01/timeshift-v19.01-amd64.run
      # sudo sh /tmp/timeshift*amd64.run
      add_ebuild "app-backup" "timeshift-bin" "$DIR/ebuilds/timeshift-bin-19.01.ebuild"
      install_packages "app-backup/timeshift-bin"
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
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'media-libs/libsdl'; then
        echo "media-libs/libsdl libcaca opengl xinerama" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q 'media-libs/audiofile'; then
        echo "media-libs/audiofile flac" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "sys-devel/binutils sys-devel/gcc sys-devel/make dev-lang/perl sys-devel/patch"
      install_packages "sys-kernel/linux-headers"
      install_packages "app-emulation/virtualbox-bin"

      sudo gpasswd -a $(whoami) vboxusers
      sudo modprobe vboxdrv
      sudo modprobe vboxnetadp
      sudo modprobe vboxnetflt
      sudo modprobe vboxpci

      if [ -f /etc/modules-load.d/networking.conf ]; then
        echo '
vboxdrv
vboxnetadp
vboxnetflt
vboxpci
' | sudo tee /etc/modules-load.d/networking.conf
      else
        echo '
vboxdrv
vboxnetadp
vboxnetflt
vboxpci
' | sudo tee -a /etc/modules-load.d/networking.conf
      fi

      sudo systemctl start systemd-modules-load
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
      install_packages "net-firewall/ufw"
      sudo /usr/share/ufw/check-requirements
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
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/bluez'; then
        echo "net-wireless/bluez cups user-session" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/blueman'; then
        echo "net-wireless/blueman pulseaudio appindicator network policykit" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "net-wireless/bluez net-wireless/blueman"

      echo "
load-module module-bluetooth-policy
load-module module-bluetooth-discover
" | sudo tee -a /etc/pulse/system.pa

      if sudo cat /etc/bluetooth/main.conf | grep -q "^AutoEnable"; then
        echo 'AutoEnable=true' | sudo tee -a /etc/bluetooth/main.conf
      else
        sudo sed -i "s/AutoEnable=.*/AutoEnable=true/g" /etc/bluetooth/main.conf
      fi

      sed -i "s/# exec --no-startup-id blueman-applet/exec --no-startup-id blueman-applet/g" $HOME/.config/i3/config
      sed -i "s/# for_window \[class=\"Blueman-manager\"\]/for_window \[class=\"Blueman-manager\"\]/g" $HOME/.config/i3/config

      sudo gpasswd -a $(whoami) plugdev
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
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-fs/samba'; then
        echo "net-fs/samba client cups syslog iprint" | sudo tee -a /etc/portage/package.use/flags
      fi

      user=$(whoami)
      install_packages "net-fs/samba"

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

      sudo systemctl enable smbd
      sudo systemctl restart smbd
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
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/bluez'; then
        echo "net-wireless/bluez cups" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-print/cups'; then
        echo "
net-print/cups usb dbus
net-print/cups-filters dbus tiff pdf zeroconf
" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "net-print/cups net-print/cups-pdf"

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
#       install_packages "hfsutils hfsplusutils"
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
      install_packages "sys-fs/fuse sys-libs/zlib app-arch/bzip2"
      install_packages "dev-util/cmake sys-devel/gcc dev-vcs/git"

      git clone https://github.com/sgan81/apfs-fuse.git
      cd apfs-fuse && git submodule init && git submodule update
      rm -rf build && mkdir build && cd build && cmake .. && make
      sudo cp -raf  ./apfs-* /usr/local/bin/
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
      install_packages "sys-boot/os-prober"
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
            if ! sudo cat /etc/portage/package.use/flags | grep -q 'sys-boot/refind'; then
              echo "sys-booot/refind ext4 btrfs hfs ntfs" | sudo tee -a /etc/portage/package.use/flags
            fi

            install_packages "sys-boot/refind"
            sudo refind-install

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
            if ! sudo cat /etc/portage/package.use/flags | grep -q 'sys-boot/refind'; then
              echo "sys-booot/refind ext4 btrfs hfs ntfs" | sudo tee -a /etc/portage/package.use/flags
            fi

            install_packages "sys-boot/refind"
            sudo refind-install
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
      install_packages "gnome-base/gnome-keyring"
      install_packages "net-im/skypeforlinux"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* )
      install_packages "media-gfx/gimp"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* )
      install_packages "mail-client/geary"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'gnome-extra/evolution-data-server'; then
        echo "gnome-extra/evolution-data-server google" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "gnome-extra/gnome-calendar"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* )
      install_packages "gnome-extra/gnome-calculator"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GParted [yN]?   " igp
  case $igp in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'sys-block/gparted'; then
        echo "sys-block/gparted btrfs fat hfs ntfs policykit" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "sys-block/gparted"
      break;;
    * ) break;;
  esac
done

