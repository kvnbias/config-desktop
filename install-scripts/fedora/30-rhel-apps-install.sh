
#!/bin/bash
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

sudo dnf -y upgrade

sudo dnf install -y curl vim-enhanced wget git gedit bash-completion polkit-gnome --releasever=$fedver

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

sudo dnf install -y exfat-utils fuse-exfat ntfs-3g eog firefox --releasever=$fedver
sudo dnf install -y libreoffice libreoffice-gtk3 vlc transmission-gtk mupdf xarchiver p7zip evince --releasever=$fedver

while true; do
  read -p "Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* ) sudo dnf install -y simplescreenrecorder --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Timeshift [yN]?  " its
  case $its in
    [Yy]* ) sudo dnf install -y timeshift --releasever=$fedver; break;;
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
      if [ "$os" = "fedora" ]; then
        wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
      else
        wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
      fi

      sudo mv virtualbox.repo /etc/yum.repos.d/virtualbox.repo
      sudo dnf update

      sudo dnf install -y binutils gcc make perl patch libgomp glibc-headers glibc-devel --releasever=$fedver
      sudo dnf install -y kernel-headers kernel-devel dkms qt5-qtx11extras libxkbcommon --releasever=$fedver

      sudo dnf remove -y VirtualBox --releasever=$fedver
      sudo dnf remove -y VirtualBox-server --releasever=$fedver
      sudo dnf remove -y akmod-VirtualBox --releasever=$fedver
      sudo dnf remove -y kmod-VirtualBox --releasever=$fedver
      sudo dnf remove -y virtualbox-guest-additions --releasever=$fedver

      sudo dnf install -y VirtualBox-6.0 --releasever=$fedver
      sudo dnf install -y virtualbox-guest-additions --releasever=$fedver

      sudo /usr/lib/virtualbox/vboxdrv.sh setup
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install firewall [yN]?   " ifw
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
  read -p "Install bluetooth [yN]?   " ibt
  case $ibt in
    [Yy]* )
      sudo dnf install -y bluez blueman pulseaudio-module-bluetooth --releasever=$fedver
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
      sudo dnf install -y samba --releasever=$fedver

      mkdir -p "/home/$user/Share"
      sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bup
      sudo cp -raf "$DIR/../../system-confs/smb.conf" "/etc/samba/smb.conf"
      sudo sed -i "s/ACCOUNT_NAME/ACCOUNT_NAME/g" /etc/samba/smb.conf

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
      sudo dnf install -y cups bluez-cups cups-pdf nss-mdns --releasever=$fedver

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
  read -p "Install Skype [yN]?   " is
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
  read -p "Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* ) sudo dnf install -y gimp --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* ) sudo dnf install -y geary --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* ) sudo dnf install -y gnome-calendar --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* ) sudo dnf install -y gnome-calculator --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GParted [yN]?   " igp
  case $igp in
    [Yy]* ) sudo dnf install -y gparted --releasever=$fedver; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Dev Tools [yN]?   " idt
  case $idt in
    [Yy]* )
      sudo dnf install -y lsof httpie tmux htop --releasever=$fedver

      sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
      sudo dnf update
      sudo dnf install -y code --releasever=$fedver
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
            sudo sh -c 'echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
            sudo dnf update
            sudo dnf install -y google-chrome-stable --releasever=$fedver
            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install Zeal [yN]?   " iz
        case $iz in
          [Yy]* ) sudo dnf install -y zeal --releasever=$fedver; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install DBeaver [yN]?   " idbvr
        case $idbvr in
          [Yy]* )
            cd /tmp
            wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
            sudo dnf install -y dbeaver-ce-latest-stable.x86_64.rpm --releasever=$fedver
            break;;
          * ) break;;
        esac
      done
      break;;
    * ) break;;
  esac
done

sudo dnf -y autoremove
