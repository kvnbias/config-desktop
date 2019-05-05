
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo pacman -Syyu
yes | sudo pacman -S curl wget vim git gedit bash-completion

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

yes | sudo pacman -S exfat-utils fuse-exfat ntfs-3g
yes | sudo pacman -S eog firefox libreoffice-fresh vlc xarchiver p7zip evince
yes | sudo pacman -S transmission-gtk --noconfirm

while true; do
  read -p "Install Screen Recorder [yN]?  " isr
  case $isr in
    [Yy]* ) yes | sudo pacman -S simplescreenrecorder; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Timeshift [yN]?  " its
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
  read -p "Install virtualbox [yN]?   " ivb
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
  read -p "Install firewall [yN]?   " ifw
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
  read -p "Install bluetooth [yN]?   " ibt
  case $ibt in
    [Yy]* )
      yes | sudo pacman -S bluez bluez-utils blueman pulseaudio-bluetooth
      cat "$DIR/../../system-confs/system.pa" | sudo tee -a /etc/pulse/system.pa
      sed -i 's/# exec --no-startup-id blueman-applet/exec --no-startup-id blueman-applet/g' $HOME/.config/i3/config
      sed -i "s/# for_window \[class=\"Blueman-manager\"\] floating enable normal/for_window \[class=\"Blueman-manager\"\] floating enable normal/g" $HOME/.config/i3/config
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
      yes | sudo pacman -S samba
      mkdir -p "$HOME/Share"
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

while true; do
  read -p "Will mount APFS partitions [yN]?   " mapfs
  case $mapfs in
    [Yy]* ) yes | yay -S apfs-fuse-git; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Skype [yN]?   " is
  case $is in
    [Yy]* ) yes | sudo pacman -S gnome-keyring; yes | yay -S skypeforlinux-stable-bin; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* ) yes | sudo pacman -S gimp; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* ) yes | sudo pacman -S geary; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calendar [yN]?   " ic
  case $ic in
    [Yy]* ) yes | sudo pacman -S geoclue; yes | yay -S gnome-calendar-no-evolution; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* ) yes | sudo pacman -S gnome-calculator; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GParted [yN]?   " igp
  case $igp in
    [Yy]* ) yes | sudo pacman -S gparted; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Dev Tools [yN]?   " idt
  case $idt in
    [Yy]* )
      yes | sudo pacman -S lsof httpie tmux htop code

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
            yes | yay -S google-chrome --noconfirm
            break;;
          * ) break;;
        esac
      done
 
      while true; do
        read -p "Install Zeal [yN]?   " iz
        case $iz in
          [Yy]* ) yes | sudo pacman -S zeal; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install DBeaver [yN]?   " idbvr
        case $idbvr in
          [Yy]* ) yes | sudo pacman -S dbeaver; break;;
          * ) break;;
        esac
      done
      break;;
    * ) break;;
  esac
done

yes | sudo pacman -Rns $(pacman -Qtdq)
