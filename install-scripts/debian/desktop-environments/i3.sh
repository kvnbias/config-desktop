
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

# Install window tiling manager
sudo apt install -y --no-install-recommends i3 i3status i3lock rxvt-unicode

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
      sudo apt install -y --no-install-recommends gdebi
      sudo mkdir -p /usr/local/compiled/{repository,sources,builds}
      sudo chown -R $(whoami):$(id -gn) /usr/local/compiled
      sudo ln -sf /usr/local/compiled/repository /usr/local/repository

      sudo apt install -y --no-install-recommends curl wget vim git gedit
      sudo apt install -y --no-install-recommends papirus-icon-theme
      sudo apt install -y --no-install-recommends feh arandr lxappearance xbacklight x11-xserver-utils xinput

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      sudo apt install -y --no-install-recommends alsa-utils
      sudo apt install -y --no-install-recommends pulseaudio pulseaudio-utils pavucontrol

      sudo apt install -y --no-install-recommends $(cat $DIR/../controls/pa-applet-20181009 | grep "BuildDepends:" | awk -F 'BuildRequires: ' '{print $2}' | sed -e "s/,/ /g")
      mkdir -p /usr/local/compiled/builds/pa-applet/debian
      cp -raf $DIR/../controls/pa-applet-20181009 /usr/local/compiled/builds/pa-applet/debian/control
      git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git /usr/local/compiled/sources/pa-applet
      cd /usr/local/compiled/sources/pa-applet && ./autogen.sh && ./configure && make
      mkdir -p /usr/local/compiled/builds/pa-applet/usr/local/bin
      cp -raf /usr/local/compiled/sources/pa-applet/src/pa-applet /usr/local/compiled/builds/pa-applet/usr/local/bin/pa-applet
      dpkg-deb -b /usr/local/compiled/builds/pa-applet pa-applet-201081009.amd64.deb

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      sudo apt install -y --no-install-recommends network-manager network-manager-gnome
      sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
      sudo systemctl enable NetworkManager

      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

      sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
      sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
      sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"

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

      # MANUAL 2.12.c: i3lock-color. Some are already installed
      sudo apt remove -y i3lock
      if [ "$os" != "debian" ]; then
        sudo apt install -y --no-install-recommends libjpeg62-dev
      else
        sudo apt install -y --no-install-recommends libjpeg62-turbo-dev
      fi

      sudo apt install -y --no-install-recommends libcairo2-dev libev-dev libturbojpeg0-dev libxcb-composite0-dev libxkbcommon-x11-dev libxcb-randr0-dev
      sudo apt install -y --no-install-recommends libpam0g-dev libxcb-util0-dev libxcb-image0-dev libxcb-xrm-dev libxcb-xinerama0-dev
      sudo apt install -y --no-install-recommends autoconf automake

      if [ "$os" != "debian" ]; then
        sudo apt install -y --no-install-recommends libturbojpeg libjpeg62
      else
        sudo apt install -y --no-install-recommends libturbojpeg0 libjpeg62-turbo
      fi

      sudo apt install -y --no-install-recommends libcairo2 libev4 libxcb-composite0 libxkbcommon-x11-0 libxcb-randr0
      sudo apt install -y --no-install-recommends libxkbcommon0 libxcb1 libxcb-image0 libxcb-xinerama0

      git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
      cd i3lock-color && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag

      git tag -f "git-$(git rev-parse --short HEAD)"
      autoreconf -fi && ./configure && make && sudo make install
      echo "auth include login" | sudo tee /etc/pam.d/i3lock
      cd /tmp

      sudo apt install -y --no-install-recommends ranger vifm

      sudo apt install -y --no-install-recommends file libcaca0 python3-pygments atool libarchive13 unrar lynx
      sudo apt install -y --no-install-recommends mupdf transmission-cli mediainfo odt2txt python3-chardet

      sudo apt install -y --no-install-recommends rofi

      # MANUAL 4.16.1: i3-gaps
      sudo apt remove -y i3
      sudo apt install -y --no-install-recommends libxcb-util0-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libxcb-icccm4-dev
      sudo apt install -y --no-install-recommends libxcb-xrm-dev libyajl-dev libxrandr-dev libstartup-notification0-dev
      sudo apt install -y --no-install-recommends libev-dev libxcb-cursor-dev libxinerama-dev libxkbcommon-dev libxkbcommon-x11-dev
      sudo apt install -y --no-install-recommends libxcb-randr0-dev libpcre3-dev libpango1.0-dev automake git gcc

      sudo apt install -y --no-install-recommends libev4 libxkbcommon-x11-0 perl libpango1.0-0 libstartup-notification0 libxcb-icccm4
      sudo apt install -y --no-install-recommends libxcb-randr0 libxcb-cursor0 libxcb-keysyms1 libxcb-xrm0 libyajl2 libxcb-xinerama0

      git clone --recurse-submodules https://github.com/Airblader/i3.git i3-gaps
      cd i3-gaps && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag

      git tag -f "git-$(git rev-parse --short HEAD)"
      autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/
      ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
      make && sudo make install
      cd /tmp

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      sudo apt install -y --no-install-recommends mpd mpc ncmpcpp
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      # MANUAL 3.3.1: polybar
      sudo apt install -y --no-install-recommends libasound2-dev libcairo2-dev xcb-proto libxcb-util0-dev libxcb-cursor-dev libxcb-image0-dev libxcb-xrm-dev
      sudo apt install -y --no-install-recommends libcurl4-openssl-dev libjsoncpp-dev libmpdclient-dev libpulse-dev libnl-3-dev libiw-dev
      sudo apt install -y --no-install-recommends libxcb-composite0-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-randr0-dev
      sudo apt install -y --no-install-recommends g++ gcc python git pkgconf cmake

      sudo apt install -y --no-install-recommends libasound2 libasound2 alsa-tools libcairo2 libxcb-cursor0 libxcb-image0 libxcb-xrm0 libxcb-icccm4 libxcb-ewmh2 libxcb-composite0
      sudo apt install -y --no-install-recommends curl libjsoncpp1 libmpdclient2 libpulse0 libnl-3-200 wireless-tools python-xcbgen libxcb-randr0

      git clone --recurse-submodules https://github.com/jaagr/polybar.git
      cd polybar && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag

      git tag -f "git-$(git rev-parse --short HEAD)"
      rm -rf build/ && mkdir -p build && cd build/
      cmake .. && make -j$(nproc) && sudo make install
      cd /tmp

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
