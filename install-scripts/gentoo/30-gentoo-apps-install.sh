
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
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

install_packages "net-misc/curl net-misc/wget app-editors/vim app-editors/gedit"
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

install_packages "sys-fs/exfat-utils sys-fs/fuse-exfat sys-fs/ntfs3g"
install_packages "media-gfx/eog www-client/firefox-bin app-office/libreoffice-bin"

if ! sudo cat /etc/portage/package.use/flags | grep -q 'media-video/vlc'; then
  echo "media-video/vlc gstreamer libass matroska faad flac mp3 mpeg ogg v4l vaapi vdpau x264 fontconfig srt" | sudo tee -a /etc/portage/package.use/flags
fi

if ! sudo cat /etc/portage/package.use/flags | grep -q 'app-arch/p7zip'; then
  echo "app-arch/p7zip rar" | sudo tee -a /etc/portage/package.use/flags
fi

install_packages "media-video/vlc net-p2p/transmission app-text/mupdf app-arch/xarchiver app-arch/p7zip app-text/evince"

while true; do
  read -p "Install Screen Recorder [yN]?  " isr
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

while true; do
  read -p "Install Timeshift [yN]?  " its
  case $its in
    [Yy]* )
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
  read -p "Install virtualbox [yN]?   " ivb
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
        sudo cp -raf $DIR/../../system-confs/networking.conf  /etc/modules-load.d/networking.conf
      else
        cat $DIR/../../system-confs/networking.conf | sudo tee -a /etc/modules-load.d/networking.conf
      fi

      sudo systemctl start systemd-modules-load
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install firewall [yN]?   " ifw
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
  read -p "Install bluetooth [yN]?   " ibt
  case $ibt in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/bluez'; then
        echo "net-wireless/bluez cups user-session" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/blueman'; then
        echo "net-wireless/blueman pulseaudio appindicator network policykit" | sudo tee -a /etc/portage/package.use/flags
      fi

      install_packages "net-wireless/bluez net-wireless/blueman"
      cat "$DIR/../../system-confs/system.pa" | sudo tee -a /etc/pulse/system.pa

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

while true; do
  read -p "Install Samba [yN]?   " ismb
  case $ismb in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-fs/samba'; then
        echo "net-fs/samba client cups syslog iprint" | sudo tee -a /etc/portage/package.use/flags
      fi

      user=$(whoami)
      install_packages "net-fs/samba"

      mkdir -p "$HOME/Share"
      sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bup
      sudo cp -raf "$DIR/../../system-confs/smb.conf" "/etc/samba/smb.conf"
      sudo sed -i "s/ACCOUNT_NAME/$user/g" /etc/samba/smb.conf

      if [ -d /etc/ufw/applications.d ]; then
        sudo cp -raf "$DIR/../../system-confs/ufw-samba" "/etc/ufw/applications.d/ufw-samba"
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
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-wireless/bluez'; then
        echo "net-wireless/bluez cups" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q 'net-print/cups'; then
        echo "net-print/cups usb dbus" | sudo tee -a /etc/portage/package.use/flags
        echo "net-print/cups-filters dbus tiff pdf zeroconf" | sudo tee -a /etc/portage/package.use/flags
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

while true; do
  read -p "Will mount APFS partitions [yN]?   " mapfs
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
  read -p "Install Skype [yN]?   " is
  case $is in
    [Yy]* )
      install_packages "gnome-base/gnome-keyring"
      install_packages "net-im/skypeforlinux"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GIMP [yN]?   " ig
  case $ig in
    [Yy]* ) install_packages "media-gfx/gimp"; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Mail Client: Geary [yN]?   " it
  case $it in
    [Yy]* ) install_packages "mail-client/geary"; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install Calendar [yN]?   " ic
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
  read -p "Install Calculator [yN]?   " ic
  case $ic in
    [Yy]* ) install_packages "gnome-extra/gnome-calculator"; break;;
    * ) break;;
  esac
done

while true; do
  read -p "Install GParted [yN]?   " igp
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

while true; do
  read -p "Install Dev Tools [yN]?   " idt
  case $idt in
    [Yy]* )
      sudo install_packages "net-misc/httpie sys-process/lsof dev-vcs/git app-misc/tmux sys-process/htop"
 
      add_ebuild "app-editors" "vscode-bin" "$DIR/ebuilds/vscode-bin-1.33.1.ebuild"
      install_packages "app-editors/vscode-bin"
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
          [Yy]* ) sudo install_packages "www-client/google-chrome"; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install Zeal [yN]?   " iz
        case $iz in
          [Yy]* )
            if ! sudo cat /etc/portage/package.use/flags | grep -q 'dev-qt/qtprintsupport'; then
              echo "dev-qt/qtprintsupport cups" | sudo tee -a /etc/portage/package.use/flags
            fi

            if ! sudo cat /etc/portage/package.use/flags | grep -q ' dev-qt/qtnetwork'; then
              echo "dev-qt/qtnetwork networkmanager" | sudo tee -a /etc/portage/package.use/flags
            fi

            sudo install_packages "app-doc/zeal"
            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Install DBeaver [yN]?   " idbvr
        case $idbvr in
          [Yy]* )
            add_ebuild "dev-db" "dbeaver-ce-bin" "$DIR/ebuilds/dbeaver-ce-bin-6.0.3.ebuild"
            install_packages "dev-db/dbeaver-ce-bin"
            break;;
          * ) break;;
        esac
      done
    * ) break;;
  esac
done

sudo emerge --ask --depclean
