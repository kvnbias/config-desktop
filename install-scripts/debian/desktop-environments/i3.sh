
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$os" == "pop" ]; then
  os='pop-os'
fi

# Install window tiling manager
sudo apt install -y --no-install-recommends i3-wm i3status i3lock rxvt-unicode
sudo apt install -y --no-install-recommends xdotool xvkbd xbindkeys

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
      compiled="/usr/local/compiled"
      sudo apt install -y --no-install-recommends gdebi
      sudo mkdir -p $compiled/{repository,sources,builds}
      sudo chown -R $(whoami):$(id -gn) $compiled
      sudo ln -sf $compiled/repository /usr/local/repository

      sudo apt install -y --no-install-recommends curl wget vim git gedit
      sudo apt install -y --no-install-recommends papirus-icon-theme
      sudo apt install -y --no-install-recommends feh arandr lxappearance xbacklight x11-xserver-utils xinput

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      sudo apt install -y --no-install-recommends alsa-utils
      sudo apt install -y --no-install-recommends pulseaudio pulseaudio-utils pavucontrol

      ## START: pa-applet 20181009
      rm -rf $compiled/builds/pa-applet && mkdir -p $compiled/builds/pa-applet/DEBIAN
      cp -raf $DIR/../controls/pa-applet_20181009-1_amd64 $compiled/builds/pa-applet/DEBIAN/control
      sudo apt install -y --no-install-recommends $(cat $compiled/builds/pa-applet/DEBIAN/control | grep "Build-Depends:" | awk -F 'Build-Depends: ' '{print $2}' | sed -e "s/,/ /g")
      rm -rf $compiled/sources/pa-applet && git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git $compiled/sources/pa-applet
      cd $compiled/sources/pa-applet && ./autogen.sh
      ./configure --prefix=/usr/local/compiled/builds/pa-applet/usr --sysconfdir=/usr/local/compiled/builds/pa-applet/etc
      make && make install
      dpkg-deb -b $compiled/builds/pa-applet $compiled/repository/pa-applet_20181009-1_amd64.deb
      sudo gdebi -n /usr/local/repository/pa-applet_20181009-1_amd64.deb
      ## END

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      sudo apt install -y --no-install-recommends network-manager network-manager-gnome
      sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
      sudo systemctl enable NetworkManager

      ## START: nerd-fonts v2.0.0
      rm -rf $compiled/builds/nerd-fonts && mkdir -p $compiled/builds/nerd-fonts/DEBIAN
      cp -raf $DIR/../controls/nerd-fonts_v2.1.0-1_amd64 $compiled/builds/nerd-fonts/DEBIAN/control
      rm -rf $compiled/sources/nerd-fonts && mkdir -p $compiled/sources/nerd-fonts

      nfbaseurl="https://github.com/ryanoasis/nerd-fonts/raw/v2.1.0/patched-fonts"
      wget -O "$compiled/sources/nerd-fonts/Ubuntu Mono Nerd Font Complete Mono.ttf"        "$nfbaseurl/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
      wget -O "$compiled/sources/nerd-fonts/Roboto Mono Nerd Font Complete Mono.ttf"        "$nfbaseurl/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
      wget -O "$compiled/sources/nerd-fonts/Roboto Mono Bold Nerd Font Complete Mono.ttf"   "$nfbaseurl/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf"
      wget -O "$compiled/sources/nerd-fonts/Sauce Code Pro Nerd Font Complete Mono.ttf"     "$nfbaseurl/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf"

      mkdir -p "$compiled/builds/nerd-fonts/usr/share/fonts/nerd-fonts-complete/ttf"
      cp -raf  "$compiled/sources/nerd-fonts/." "$compiled/builds/nerd-fonts/usr/share/fonts/nerd-fonts-complete/ttf/"

      dpkg-deb -b $compiled/builds/nerd-fonts $compiled/repository/nerd-fonts_v2.1.0-1_amd64.deb
      sudo gdebi -n /usr/local/repository/nerd-fonts_v2.1.0-1_amd64.deb
      ## END

      sudo apt install -y --no-install-recommends neofetch
      sudo apt install -y --no-install-recommends libgtk2.0-0 libgtk-3-0

      sudo apt install -y --no-install-recommends breeze-cursor-theme
      sudo apt install -y --no-install-recommends dbus-x11 dunst conky compton w3m
      sudo apt install -y --no-install-recommends ffmpegthumbnailer

      if [ ! -d /usr/share/icons/Breeze ]; then
        sudo ln -sf /usr/share/icons/breeze_cursors /usr/share/icons/Breeze
      fi

      # https://pillow.readthedocs.io/en/stable/installation.html
      sudo apt install -y --no-install-recommends python3-pip
      sudo apt install -y --no-install-recommends poppler-utils mediainfo transmission-cli transmission-common
      sudo apt install -y --no-install-recommends zip unzip tar xz-utils unrar catdoc docx2txt

      if [ "$os" != "debian" ]; then
        sudo apt install -y --no-install-recommends libjpeg62-dev
      else
        sudo apt install -y --no-install-recommends libjpeg62-turbo-dev
      fi

      sudo apt install -y --no-install-recommends python3-dev libturbojpeg0-dev zlib1g-dev libxext-dev python3-setuptools
      sudo pip3 install ueberzug

      ## START: i3lock-color 2.12.c
      sudo apt remove -y i3lock
      mkdir -p $compiled/builds/i3lock-color/DEBIAN
      cp -raf $DIR/../controls/i3lock-color_2.12.c-5_amd64 $compiled/builds/i3lock-color/DEBIAN/control

      if [ "$os" != "debian" ]; then
        sed -i "s/LIBJPEG/libjpeg62/g"          $compiled/builds/i3lock-color/DEBIAN/control
        sed -i "s/LIBTURBO/libturbojpeg/g"      $compiled/builds/i3lock-color/DEBIAN/control
      else
        sed -i "s/LIBJPEG/libjpeg62-turbo/g"          $compiled/builds/i3lock-color/DEBIAN/control
        sed -i "s/LIBTURBO/libturbojpeg0/g"           $compiled/builds/i3lock-color/DEBIAN/control
      fi

      sudo apt install -y --no-install-recommends $(cat $compiled/builds/i3lock-color/DEBIAN/control | grep "Build-Depends:" | awk -F 'Build-Depends: ' '{print $2}' | sed -e "s/,/ /g")
      wget -O /tmp/i3lock-color.tar.gz $(cat $compiled/builds/i3lock-color/DEBIAN/control | grep "Source:" | awk -F 'Source: ' '{print $2}')
      rm -rf $compiled/sources/i3lock-color && mkdir -p $compiled/sources/i3lock-color
      tar xvzf /tmp/i3lock-color.tar.gz -C $compiled/sources/i3lock-color --strip-components=1
      cd $compiled/sources/i3lock-color && autoreconf -fi
      ./configure --prefix=/usr/local/compiled/builds/i3lock-color/usr --sysconfdir=/usr/local/compiled/builds/i3lock-color/etc
      make && make install
      dpkg-deb -b $compiled/builds/i3lock-color $compiled/repository/i3lock-color_2.12.c-5_amd64.deb
      sudo gdebi -n /usr/local/repository/i3lock-color_2.12.c-5_amd64.deb
      ## END

      sudo apt install -y --no-install-recommends ranger vifm

      sudo apt install -y --no-install-recommends file libcaca0 python3-pygments atool libarchive13 unrar lynx
      sudo apt install -y --no-install-recommends mupdf transmission-cli mediainfo odt2txt python3-chardet

      sudo apt install -y --no-install-recommends rofi

      # START: i3-gaps 4.16.1
      sudo apt remove -y i3-wm
      mkdir -p $compiled/builds/i3-gaps/DEBIAN
      cp -raf $DIR/../controls/i3-gaps_4.18.2-1_amd64 $compiled/builds/i3-gaps/DEBIAN/control
      sudo apt install -y --no-install-recommends $(cat $compiled/builds/i3-gaps/DEBIAN/control | grep "Build-Depends:" | awk -F 'Build-Depends: ' '{print $2}' | sed -e "s/,/ /g")
      wget -O /tmp/i3-gaps.tar.gz $(cat $compiled/builds/i3-gaps/DEBIAN/control | grep "Source:" | awk -F 'Source: ' '{print $2}')
      rm -rf $compiled/sources/i3-gaps && mkdir -p $compiled/sources/i3-gaps
      tar xvzf /tmp/i3-gaps.tar.gz -C $compiled/sources/i3-gaps --strip-components=1
      cd $compiled/sources/i3-gaps && autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/
      ../configure --prefix=/usr/local/compiled/builds/i3-gaps/usr --sysconfdir=/usr/local/compiled/builds/i3-gaps/etc --disable-sanitizers
      make && make install
      dpkg-deb -b $compiled/builds/i3-gaps $compiled/repository/i3-gaps_4.18.2-1_amd64.deb
      sudo gdebi -n /usr/local/repository/i3-gaps_4.18.2-1_amd64.deb
      ## END

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      sudo apt install -y --no-install-recommends mpd mpc ncmpcpp
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      ## START: polybar 3.3.1
      mkdir -p $compiled/builds/polybar/DEBIAN
      cp -raf $DIR/../controls/polybar_3.4.3-1_amd64 $compiled/builds/polybar/DEBIAN/control
      sudo apt install -y --no-install-recommends $(cat $compiled/builds/polybar/DEBIAN/control | grep "Build-Depends:" | awk -F 'Build-Depends: ' '{print $2}' | sed -e "s/,/ /g")
      wget -O /tmp/polybar.tar.gz $(cat $compiled/builds/polybar/DEBIAN/control | grep "Source:" | awk -F 'Source: ' '{print $2}')
      rm -rf $compiled/sources/polybar && mkdir -p $compiled/sources/polybar
      tar xvzf /tmp/polybar.tar.gz -C $compiled/sources/polybar --strip-components=1
      rm -rf $compiled/sources/polybar/lib/i3ipcpp  $compiled/sources/polybar/lib/xpp
      git clone https://github.com/polybar/i3ipcpp    $compiled/sources/polybar/lib/i3ipcpp
      git clone https://github.com/polybar/xpp        $compiled/sources/polybar/lib/xpp
      cd $compiled/sources/polybar/lib/i3ipcpp && git checkout cb008b3
      cd $compiled/sources/polybar/lib/xpp && git checkout c1a0f59
      cd $compiled/sources/polybar && rm -rf build/ && mkdir -p build && cd build/
      cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/compiled/builds/polybar/usr .. && make && make install
      dpkg-deb -b $compiled/builds/polybar $compiled/repository/polybar_3.4.3-1_amd64.deb
      sudo gdebi -n /usr/local/repository/polybar_3.4.3-1_amd64.deb
      ## END

      sudo apt install -y --no-install-recommends scrot accountsservice

      sudo apt remove -y libasound2-dev libcairo2-dev libcurl4-openssl-dev \
        libev-dev libglib2.0-dev libgtk-3-dev libiw-dev libjsoncpp-dev libmpdclient-dev \
        libnl-3-dev libnotify-dev libpam0g-dev libpango1.0-dev libpcre3-dev libpulse-dev \
        libstartup-notification0-dev libturbojpeg0-dev libx11-dev libxcb-composite0-dev \
        libxcb-cursor-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev \
        libxcb-keysyms1-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xinerama0-dev \
        libxcb-xrm-dev libxext-dev libxinerama-dev libxkbcommon-dev libxkbcommon-x11-dev \
        libxrandr-dev libyajl-dev python3-dev python3-setuptools xcb-proto zlib1g-dev

      if [ "$os" != "debian" ]; then
        sudo apt remove -y libjpeg62-dev
      else
        sudo apt remove -y libjpeg62-turbo-dev
      fi

      sudo apt autoremove -y

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

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/apt" | sudo tee -a "/etc/sudoers"

      if [ ! -f $HOME/.riced ];then
        bash $DIR/../../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      # NOTE: needs adjustment for the sake of fedora
      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

      mkdir -p "$HOME/.config/neofetch"
      cp -raf $DIR/../../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      sudo cp -raf $DIR/../../../system-confs/index.theme /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo cp -raf $DIR/../../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

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
