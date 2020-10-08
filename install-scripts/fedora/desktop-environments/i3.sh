
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

sudo dnf install -y dmenu i3 i3status i3lock rxvt-unicode --releasever=$fedver

if [ ! -f "$HOME/.riced" ];then
  mkdir -p "$HOME/.config/i3"
  cp -raf "$DIR/../../../rice/xinitrc"         "$HOME/.xinitrc"
  cp -raf "$DIR/../../../rice/base-i3-config"  "$HOME/.config/i3/config"
  cp -raf "$DIR/../../../rice/base-Xresources" "$HOME/.Xresources"
  sudo cp "$HOME/.Xresources"                  "/root/.Xresources"
fi

while true; do
  read -p "Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      sudo dnf install -y gcc make bash coreutils diffutils --releasever=$fedver
      sudo dnf install -y python rpm-build rpm-devel rpmlint patch rpmdevtools --releasever=$fedver
      rpmdev-setuptree

      sed -i "s~\$HOME~\/usr\/local~g" $HOME/.rpmmacros
      rm -rf $HOME/rpmbuild
      sudo mkdir -p /usr/local/rpmbuild/RPMS/x86_64
      sudo chown -R $(whoami):$(id -gn) /usr/local/rpmbuild
      sudo ln -sf /usr/local/rpmbuild/RPMS/x86_64 /usr/local/repository

      sudo dnf install -y curl wget vim-minimal vim-enhanced git gedit --releasever=$fedver
      sudo dnf install -y papirus-icon-theme --releasever=$fedver
      sudo dnf install -y feh arandr lxappearance xbacklight xorg-x11-server-utils --releasever=$fedver

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      sudo dnf install -y notification-daemon --releasever=$fedver

      sudo dnf install -y alsa-utils --releasever=$fedver
      sudo dnf install -y pulseaudio pulseaudio-utils pavucontrol --releasever=$fedver

      sudo dnf builddep -y $DIR/../specs/pa-applet.spec && rpmbuild -ba $DIR/../specs/pa-applet.spec
      sudo dnf install -y /usr/local/repository/pa-applet-20181009-1.fc$fedver.x86_64.rpm

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      sudo dnf install -y NetworkManager network-manager-applet --releasever=$fedver
      sudo systemctl enable NetworkManager

      rpmbuild -ba $DIR/../specs/nerd-fonts.spec
      sudo dnf install -y /usr/local/repository/nerd-fonts-2.1.0-1.fc$fedver.x86_64.rpm

      sudo dnf install -y neofetch --releasever=$fedver
      sudo dnf install -y gtk2 gtk3 --releasever=$fedver

      sudo dnf install -y breeze-cursor-theme --releasever=$fedver
      sudo dnf install -y dunst conky compton w3m --releasever=$fedver
      sudo dnf install -y ffmpegthumbnailer --releasever=$fedver

      if [ ! -d /usr/share/icons/Breeze ]; then
        sudo ln -sf /usr/share/icons/breeze_cursors /usr/share/icons/Breeze
      fi

      sudo dnf install -y python3-pip --releasever=$fedver
      sudo dnf install -y redhat-rpm-config --releasever=$fedver

      # https://pillow.readthedocs.io/en/stable/installation.html
      sudo dnf install -y python3-devel libjpeg-turbo-devel zlib-devel libXext-devel --releasever=$fedver
      sudo pip3 install ueberzug
      sudo dnf install -y poppler-utils mediainfo transmission-cli transmission-common --releasever=$fedver
      sudo dnf install -y zip unzip tar xz-libs unrar catdoc odt2txt --releasever=$fedver

      sudo dnf remove -y i3lock
      spectool -g -R $DIR/../specs/i3lock-color.spec && sudo dnf builddep -y $DIR/../specs/i3lock-color.spec && rpmbuild -ba $DIR/../specs/i3lock-color.spec
      sudo dnf install -y /usr/local/repository/i3lock-color-2.12.c-5.fc$fedver.x86_64.rpm

      sudo dnf install -y ranger vifm --releasever=$fedver

      sudo dnf install -y file libcaca python3-pygments atool libarchive unrar lynx --releasever=$fedver
      sudo dnf install -y mupdf transmission-cli mediainfo odt2txt python3-chardet --releasever=$fedver

      sudo dnf install -y rofi --releasever=$fedver

      sudo dnf remove -y i3
      spectool -g -R $DIR/../specs/i3-gaps.spec && sudo dnf builddep -y $DIR/../specs/i3-gaps.spec && rpmbuild -ba $DIR/../specs/i3-gaps.spec
      sudo dnf install -y /usr/local/repository/i3-gaps-4.18.2-1.fc$fedver.x86_64.rpm

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      # r: repeat, z: shuffle, y: repeat one
      sudo dnf install -y mpd mpc ncmpcpp --releasever=$fedver
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      # spectool -g -R $DIR/../specs/polybar.spec && sudo dnf builddep -y $DIR/../specs/polybar.spec && rpmbuild -ba $DIR/../specs/polybar.spec
      # sudo dnf install -y /usr/local/repository/polybar-3.4.3-1.fc$fedver.x86_64.rpm
      sudo dnf install -y polybar

      sudo dnf install -y scrot accountsservice --releasever=$fedver

      sudo dnf remove -y alsa-lib-devel cairo-devel glib2-devel gtk3-devel jsoncpp-devel \
        libcurl-devel libev-devel libjpeg-devel libjpeg-turbo-devel libmpdclient-devel \
        libnl3-devel libnotify-devel libX11-devel libxcb-devel libXext-devel libXinerama-devel \
        libxkbcommon-devel libxkbcommon-x11-devel libXrandr-devel pam-devel pango-devel pcre-devel \
        pulseaudio-libs-devel python3-devel startup-notification-devel wireless-tools-devel xcb-proto \
        xcb-util-cursor-devel xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-wm-devel \
        xcb-util-xrm-devel yajl-devel zlib-devel
      sudo dnf -y autoremove

      user=$(whoami)
      sudo cp -raf $DIR/../../../system-confs/account /var/lib/AccountsService/users/$user
      sudo sed -i "s/ACCOUNT_NAME/$user/g" /var/lib/AccountsService/users/$user
      sudo cp $DIR/../../../rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
      sudo cp $DIR/../../../rice/images/avatar/default-user.png /usr/share/pixmaps/default-user.png
      sudo chown root:root /var/lib/AccountsService/users/$user
      sudo chown root:root /var/lib/AccountsService/icons/$user.png

      sudo chmod 644 /var/lib/AccountsService/users/$user
      sudo chmod 644 /var/lib/AccountsService/icons/$user.png

      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
      bash $DIR/../../../setup-scripts/update-libinput.sh

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/dnf" | sudo tee -a "/etc/sudoers"

      if [ ! -f $HOME/.riced ];then
        bash $DIR/../../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      cd $mainCWD

      mkdir -p "$HOME/.config/neofetch"
      cp -raf $DIR/../../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      sudo cp -raf $DIR/../../../system-confs/index.theme /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo cp -raf $DIR/../../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

      bash $DIR/../../../setup-scripts/update-scripts.sh
      bash $DIR/../../../setup-scripts/update-screen-detector.sh
      bash $DIR/../../../setup-scripts/update-themes.sh

      echo '

####################################
####################################
###                              ###
###    RICING COMPLETE...        ###
###                              ###
####################################
####################################

'

      break;;
  esac
done
