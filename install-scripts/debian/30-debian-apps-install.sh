
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo apt -y upgrade
sudo apt install -y --no-install-recommends vim curl wget git gedit bash-completion policykit-1-gnome

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

sudo apt install -y --no-install-recommends exfat-utils exfat-fuse ntfs-3g eog vlc transmission-gtk
sudo apt install -y --no-install-recommends libreoffice libreoffice-gtk3 libreoffice-style-breeze mupdf xarchiver p7zip evince

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
Icon=" | sudo tee /usr/share/applications/firefox.desktop

  echo "
[Desktop Entry]
Name=Firefox Update
Comment=Manually downloaded firefox
Exec=/bin/bash -c \"notify-send -i $HOME/.config/firefox/noicon -t 5000 'Firefox' 'Downloading firefox'; wget -O /tmp/FirefoxSetup.tar.bz2 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US'; notify-send -i $HOME/.config/firefox/noicon -t 5000 'Firefox' 'Updating firefox';tar xjf /tmp/FirefoxSetup.tar.bz2 -C /opt/firefox/; notify-send -i $HOME/.config/firefox/noicon -t 5000 'Firefox' 'Firefox updated'\"
Terminal=false
Type=Application
Icon=
" | sudo tee /usr/share/applications/firefox-update.desktop
fi

while true; do
  read -p "Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* ) sudo apt install -y --no-install-recommends simplescreenrecorder; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
      [ "$os" != "debian" ] && sudo add-apt-repository ppa:teejee2008/ppa
      sudo apt update
      sudo apt install -y --no-install-recommends timeshift
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
  read -p "Install bluetooth [yN]?   " ibt
  case $ibt in
    [Yy]* )
      sudo apt install -y --no-install-recommends bluez blueman pulseaudio-module-bluetooth
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
      sudo apt install -y --no-install-recommends samba
      mkdir -p "$HOME/Share"
      sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bup
      sudo cp -raf "$DIR/../../system-confs/smb.conf" "/etc/samba/smb.conf"
      sudo sed -i "s/ACCOUNT_NAME/$user/g" /etc/samba/smb.conf

      if [ -d /etc/ufw/applications.d ]; then
        # sudo cp -raf "$DIR/../../system-confs/ufw-samba" "/etc/ufw/applications.d/ufw-samba"
        sudo ufw allow Samba
      fi

      sudo systemctl enable smbd
      sudo systemctl restart smbd
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install CUPS [yN]?   " ic
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

while true; do
  read -p "Install Skype [yN]?   " is
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
  read -p "Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* ) sudo apt install -y --no-install-recommends gimp; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* ) sudo apt install -y --no-install-recommends geary; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* ) sudo apt install -y --no-install-recommends gnome-calendar; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* ) sudo apt install -y --no-install-recommends gnome-calculator; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GParted [yN]?   " igp
  case $igp in
    [Yy]* ) sudo apt install -y --no-install-recommends gparted; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Dev Tools [yN]?   " idt
  case $idt in
    [Yy]* )
      sudo apt install -y --no-install-recommends htop

      sudo apt install -y --no-install-recommends apt-transport-https gnupg2 curl
      sudo apt install -y docker docker-compose

      if grep -q docker /etc/group; then
        echo 'group already exists'
      else
        sudo groupadd docker
      fi

      sudo usermod -aG docker $USER
      newgrp docker &
      #sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
      #sudo chmod g+rwx "$HOME/.docker" -R

      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      sudo apt update
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
      sudo apt update
      sudo apt install -y --no-install-recommends kubectl

      cd /tmp
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
      sudo dpkg -i minikube_latest_amd64.deb

      sudo apt install -y --no-install-recommends vagrant

      cd /tmp
      curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
      sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
      sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

      sudo apt install --no-install-recommends apt-transport-https
      sudo apt update
      sudo apt install --no-install-recommends code

      echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
      sudo sysctl -p

      while true; do
        read -p "Enable vim mode on VSCode [yN]?   " evm
        case $evm in
          [Yy]* )
            code --install-extension vscodevim.vim &
            break;;
          *) break;;
        esac
      done
 
      code --install-extension eamodio.gitlens &
      code --install-extension ms-azuretools.vscode-docker &
      code --install-extension ms-vscode-remote.remote-containers &
      code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools &
      code --install-extension ms-kubernetes-tools.vscode-aks-tools &
      code --install-extension ms-vscode.theme-tomorrowkit &

      sleep 20

      while true; do
        read -p "Install Google Chrome [yN]?   " igc
        case $igc in
          [Yy]* )
            sudo apt install -y --no-install-recommends fonts-liberation
            cd /tmp
            wget  -O "google-chrome-stable_current_amd64.deb"  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
            sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb 
            break;;
          * ) break;;
        esac
      done
 
      while true; do
        read -p "Install Zeal [yN]?   " iz
        case $iz in
          [Yy]* ) sudo apt install -y --no-install-recommends zeal; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install MySQL [yN]?   " idbvr
        case $idbvr in
          [Yy]* )
            sudo apt install --no-install-recommends mysql-server

            cd /tmp
            wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
            echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
            sudo apt update
            sudo apt install --no-install-recommends dbeaver-ce
            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install MongoDB [yN]?   " imdb
        case $imdb in
          [Yy]* )
            sudo apt install --no-install-recommends mongodb
            cd /tmp
            fileName="mongodb-compass_1.22.1_amd64.deb"
            wget "https://downloads.mongodb.com/compass/$fileName"
            sudo dpkg -i /tmp/$fileName
            break;;
          * ) break;;
        esac
      done

      break;;
    * ) break;;
  esac
done

sudo apt -y autoremove

