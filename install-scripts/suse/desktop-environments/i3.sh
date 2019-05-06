
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

# Install window tiling manager
sudo zypper -n install --no-recommends dmenu i3 i3status i3lock rxvt-unicode

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
      sudo zypper -n install --no-recommends gcc make bash coreutils diffutils
      sudo zypper -n install --no-recommends python rpm-build rpm-devel rpmlint patch rpmdevtools
      rpmdev-setuptree

      sed -i "s~\$HOME~\/usr\/local~g" $HOME/.rpmmacros
      rm -rf $HOME/rpmbuild
      sudo mkdir -p /usr/local/rpmbuild/RPMS/x86_64
      sudo chown -R $(whoami):$(id -gn) /usr/local/rpmbuild
      sudo ln -sf /usr/local/rpmbuild/RPMS/x86_64 /usr/local/repository
      sudo cp -raf $DIR/../../../system-confs/local.repo /etc/zypp/repos.d/local.repo

      sudo zypper -n install --no-recommends curl wget vim git gedit
      sudo zypper -n install --no-recommends papirus-icon-theme
      sudo zypper -n install --no-recommends feh lxappearance xbacklight xrandr xrdb xinput

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      sudo zypper -n install --no-recommends notification-daemon

      sudo zypper -n install --no-recommends alsa-utils libnotify-tools
      sudo zypper -n install --no-recommends pulseaudio pulseaudio-utils pavucontrol

      sudo zypper -n install --no-recommends $(cat $DIR/../specs/pa-applet.spec | grep "BuildRequires" | awk -F 'BuildRequires:  ' '{print $2}')
      rpmbuild -ba $DIR/../specs/pa-applet.spec
      sudo zypper inr -r local && sudo zypper -n install --no-recommends pa-applet

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      sudo zypper -n install --no-recommends NetworkManager-branding-openSUSE NetworkManager-applet
      sudo systemctl enable NetworkManager

      rpmbuild -ba $DIR/../specs/nerd-fonts.spec
      sudo zypper inr -r local && sudo zypper -n install --no-recommends nerd-fonts

      sudo zypper -n install --no-recommends neofetch
      sudo zypper -n install --no-recommends gtk2-branding-openSUSE gtk3-branding-openSUSE

      sudo zypper -n install --no-recommends breeze5-cursors
      sudo ln -sf /usr/share/icons/breeze_cursors /usr/share/icons/Breeze
      sudo zypper -n install --no-recommends dbus-1-x11 dunst conky compton w3m
      sudo zypper -n install --no-recommends ffmpegthumbnailer

      sudo zypper -n install --no-recommends python3-pip

      # https://pillow.readthedocs.io/en/stable/installation.html
      sudo zypper -n install --no-recommends libjpeg62
      sudo zypper -n install --no-recommends python3-devel libjpeg62-devel zlib-devel libXext-devel
      sudo pip3 install ueberzug
      sudo zypper -n install --no-recommends poppler-tools mediainfo transmission transmission-common
      sudo zypper -n install --no-recommends zip unzip tar xz unrar odt2txt

      sudo zypper -n remove i3lock
      rpmdev-spectool -g -R $DIR/../specs/i3lock-color.spec
      sudo zypper -n install --no-recommends $(cat $DIR/../specs/i3lock-color.spec | grep "BuildRequires" | awk -F 'BuildRequires:  ' '{print $2}')
      rpmbuild -ba $DIR/../specs/i3lock-color.spec
      sudo zypper inr -r local && sudo zypper -n install --no-recommends i3lock-color

      sudo zypper -n install --no-recommends ranger vifm

      sudo zypper -n install --no-recommends file libcaca0 python3-Pygments atool libarchive13 unrar lynx
      sudo zypper -n install --no-recommends mupdf transmission transmission-common mediainfo odt2txt python3-chardet

      sudo zypper -n install --no-recommends rofi
      sudo zypper -n remove i3
      sudo zypper -n install --no-recommends i3-gaps

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press
      # r: repeat, z: shuffle, y: repeat one
      sudo zypper -n install --no-recommends mpd mpclient ncmpcpp
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      rpmdev-spectool -g -R $DIR/../specs/polybar.spec
      sudo zypper -n install --no-recommends $(cat $DIR/../specs/polybar.spec | grep "BuildRequires" | awk -F 'BuildRequires:  ' '{print $2}')
      rpmbuild -ba $DIR/../specs/polybar.spec
      sudo zypper inr -r local && sudo zypper -n install --no-recommends polybar

      sudo zypper -n install --no-recommends scrot accountsservice

      sudo zypper remove alsa-devel cairo-devel cmake i3-gaps-devel jsoncpp-devel libcurl-devel \
        libev-devel libiw-devel libjpeg62-devel libmpdclient-devel libnl3-devel libpulse-devel \
        libxkbcommon-x11-devel pam-devel python-xml xcb-proto-devel xcb-util-cursor-devel xcb-util-devel \
        xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel
      sudo zypper remove -u $(zypper packages --unneeded | grep -v '+-' | grep -v '\.\.\.' | grep -v 'Version' | cut -f 3 -d '|')

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

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/zypper" | sudo tee -a "/etc/sudoers"
      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/yast" | sudo tee -a "/etc/sudoers"

      if [ ! -f $HOME/.riced ];then
        bash $DIR/../../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      sudo ln -sf /usr/bin/urxvt-256color /usr/bin/urxvt256c-ml

      mkdir -p "$HOME/.config/neofetch"
      cp -rf $DIR/../../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf
      sed -i "s/ascii_distro=.*/ascii_distro=\"opensuse\"/g" $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      sudo cp -raf $DIR/../../../system-confs/index.theme /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo cp -rf $DIR/../../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

      bash $DIR/../../../setup-scripts/update-scripts.sh
      bash $DIR/../../../setup-scripts/update-screen-detector.sh
      bash $DIR/../../../setup-scripts/update-themes.sh

      echo '

#####################################
#####################################
####                              ###
####    RICING COMPLETE...        ###
####                              ###
#####################################
#####################################

'

      break;;
  esac
done


