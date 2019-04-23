
#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo apt -y upgrade

sudo apt install -y --no-install-recommends vim curl wget httpie git tmux gedit
sudo apt install -y --no-install-recommends lsof bash-completion gamin policykit-1-gnome

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
sudo apt install -y --no-install-recommends exfat-utils exfat-fuse ntfs-3g

# media
sudo apt install -y --no-install-recommends eog

# firefox

if [ "$os" != "debian" ]; then
  sudo apt install -y --no-install-recommends firefox
else
  # sudo apt install -y --no-install-recommends firefox-esr
  wget -O /tmp/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
  sudo mkdir -p /opt/firefox
  sudo tar xjf /tmp/FirefoxSetup.tar.bz2 -C /opt/firefox/
  sudo ln -sf /opt/firefox/firefox/firefox /usr/bin/firefox

  echo "
[Desktop Entry]
Name=Firefox
Comment=Manually downloaded firefox
Exec=firefox
Terminal=false
Type=Application
Icon=" | tee /home/$(whoami)/.local/share/applications/firefox.desktop

  echo "
[Desktop Entry]
Name=Firefox Update
Comment=Manually downloaded firefox
Exec=/bin/bash -c \"notify-send -i /home/$(whoami)/.config/firefox/noicon -t 5000 'Firefox' 'Downloading firefox'; wget -O /tmp/FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'; notify-send -i /home/$(whoami)/.config/firefox/noicon -t 5000 'Firefox' 'Updating firefox';tar xjf /tmp/FirefoxSetup.tar.bz2 -C /opt/firefox/; notify-send -i /home/$(whoami)/.config/firefox/noicon -t 5000 'Firefox' 'Firefox updated'\"
Terminal=false
Type=Application
Icon=
" | tee /home/$(whoami)/.local/share/applications/firefox-update.desktop
fi

# extra
sudo apt install -y --no-install-recommends libreoffice libreoffice-gtk3 libreoffice-style-breeze
sudo apt install -y --no-install-recommends vlc transmission-gtk mupdf xarchiver p7zip evince

while true; do
  read -p "

Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* )
      sudo apt install -y --no-install-recommends simplescreenrecorder
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
#       sudo apt install -y --no-install-recommends flatpak
#       sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#       flatpak install -y --no-install-recommends flathub org.jdownloader.JDownloader
#       break;;
#     * ) break;;
#   esac
# done

while true; do
  read -p "

Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      if [ "$os" != "debian" ]; then
        sudo add-apt-repository ppa:teejee2008/ppa
        sudo apt update
        sudo apt install -y --no-install-recommends timeshift
      else
        sudo apt install -y --no-install-recommends timeshift
      fi


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
      sudo apt install -y --no-install-recommends binutils gcc make perl patch libgomp1
      sudo apt install -y --no-install-recommends linux-headers-$(uname -r) dkms libxkbcommon0

      sudo apt install -y --no-install-recommends virtualbox
      sudo apt install -y --no-install-recommends virtualbox-qt
      sudo apt install -y --no-install-recommends virtualbox-guest-additions-iso

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
      sudo apt install -y --no-install-recommends ufw gufw
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
      sudo apt install -y --no-install-recommends bluez blueman pulseaudio-module-bluetooth

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
      sudo apt install -y --no-install-recommends samba

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
      sudo apt install -y --no-install-recommends avahi-daemon cups bluez-cups printer-driver-cups-pdf libnss-mdns

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
#       sudo apt install -y --no-install-recommends hfsutils hfsplus hfsprogs
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
      sudo apt install -y --no-install-recommends fuse zlib1g bzip2 libattr1
      sudo apt install -y --no-install-recommends libfuse-dev libbz2-dev zlib1g-dev libattr1-dev
      sudo apt install -y --no-install-recommends cmake g++ git

      git clone https://github.com/sgan81/apfs-fuse.git
      cd apfs-fuse && git submodule init && git submodule update
      rm -rf build && mkdir build && cd build && cmake .. && make
      sudo cp -raf  ./apfs-* /usr/local/bin/

      sudo apt remove -y libfuse-dev libbz2-dev zlib1g-dev libattr1-dev
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
      sudo apt install -y --no-install-recommends os-prober
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
      sudo apt install -y --no-install-recommends gnome-keyring gnome-keyring-pkcs11
      sudo apt install -y --no-install-recommends gconf-service gconf2-common gcr libgconf-2-4
      sudo apt install -y --no-install-recommends libpam-gnome-keyring p11-kit p11-kit-modules pinentry-gnome3

      cd /tmp
      wget -O "skypeforlinux-64.deb" "https://go.skype.com/skypeforlinux-64.deb"
      sudo apt install -y --no-install-recommends gdebi
      sudo gdebi /tmp/skypeforlinux-64.deb
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* )
      sudo apt install -y --no-install-recommends gimp
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* )
      sudo apt install -y --no-install-recommends geary
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo apt install -y --no-install-recommends gnome-calendar
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* )
      sudo apt install -y --no-install-recommends gnome-calculator
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install GParted [yN]?   " igp
  case $igp in
    [Yy]* )
      sudo apt install -y --no-install-recommends gparted
      break;;
    * ) break;;
  esac
done

sudo apt -y autoremove

