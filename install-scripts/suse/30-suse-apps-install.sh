

#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo zypper -n update

sudo zypper -n install --no-recommends curl vim wget gedit bash-completion polkit-gnome

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

sudo zypper -n install --no-recommends exfat-utils fuse-exfat ntfs-3g eog MozillaFirefox MozillaFirefox-branding-openSUSE
sudo zypper -n install --no-recommends libreoffice libreoffice-gtk3 libreoffice-base libreoffice-writer libreoffice-math libreoffice-draw libreoffice-calc
sudo zypper -n install --no-recommends vlc transmission-gtk mupdf p7zip evince

while true; do
  read -p "Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* ) sudo zypper -n install --no-recommends simplescreenrecorder; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Timeshift [yN]?  " its
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
  read -p "Install virtualbox [yN]?   " ivb
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
  read -p "Install firewall [yN]?   " ifw
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
  read -p "Install bluetooth [yN]?   " ibt
  case $ibt in
    [Yy]* )
      sudo zypper -n install --no-recommends bluez bluez-auto-enable-devices blueman pulseaudio-module-bluetooth
      cat "$DIR/../../system-confs/system.pa" | sudo tee -a /etc/pulse/system.pa
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
  read -p "Install Samba [yN]?   " ismb
  case $ismb in
    [Yy]* )
      user=$(whoami)
      sudo zypper -n install --no-recommends samba samba-client samba-libs
      mkdir -p "$HOME/Share"
      sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bup
      sudo cp -raf "$DIR/../../system-confs/smb.conf" "/etc/samba/smb.conf"
      sudo sed -i "s/ACCOUNT_NAME/$user/g" /etc/samba/smb.conf

      if [ -d /etc/ufw/applications.d ]; then
        sudo cp -raf "$DIR/../../system-confs/ufw-samba" "/etc/ufw/applications.d/ufw-samba"
        sudo ufw allow Samba
      fi

      sudo systemctl enable smb
      sudo systemctl restart smb
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install CUPS [yN]?   " ic
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
  read -p "Will mount APFS partitions [yN]?   " mapfs
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
  read -p "Install Skype [yN]?   " is
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
  read -p "Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* ) sudo zypper -n install --no-recommends gimp; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* ) sudo zypper -n install --no-recommends geary; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* ) sudo zypper -n install --no-recommends gnome-calendar; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* ) sudo zypper -n install --no-recommends gnome-calculator; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GParted [yN]?   " igp
  case $igp in
    [Yy]* ) sudo zypper -n install --no-recommends gparted; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Dev Tools [yN]?   " idt
  case $idt in
    [Yy]* )
      sudo zypper -n install --no-recommends htop python3-httpie git tmux lsof

      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c 'echo -e "[vscode]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
      sudo zypper refresh
      sudo zypper install --no-recommends -r vscode code
      echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p
 
      while true; do
        read -p "Enable vim mode on VSCode [yN]?   " evm
        case $evm in
          [Yy]* ) code --install-extension vscodevim.vim &; break;;
          *) break;;
        esac
      done

      code --install-extension eamodio.gitlens &
      code --install-extension peterjausovec.vscode-docker &
      code --install-extension ms-vscode.theme-tomorrowkit &

      sleep 20

      while true; do
        read -p "Install Google Chrome [yN]?   " igc
        case $igc in
          [Yy]* )
            sudo sh -c 'echo -e "[google]\nname=google\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/zypp/repos.d/google.repo'
            sudo zypper refresh
            sudo zypper -n install --no-recommends -r google google-chrome-stable
            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install Zeal [yN]?   " iz
        case $iz in
          [Yy]* ) sudo zypper -n install --no-recommends zeal; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install DBeaver [yN]?   " idbvr
        case $idbvr in
          [Yy]* )
            wget -O /tmp/dbeaver-ce-latest-stable.x86_64.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
            sudo zypper install /tmp/dbeaver-ce-latest-stable.x86_64.rpm
            break;;
          * ) break;;
        esac
      done
    * ) break;;
  esac
done

sudo zypper remove -u $(zypper packages --unneeded | grep -v '+-' | grep -v '\.\.\.' | grep -v 'Version' | cut -f 3 -d '|')
