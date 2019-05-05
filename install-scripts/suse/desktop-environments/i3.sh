
#!/bin/bash

DIR/..="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

# Install window tiling manager
sudo zypper -n install --no-recommends dmenu i3 i3status i3lock rxvt-unicode

if [ ! -f "$HOME/.riced" ];then
  cp -raf "$DIR/../../../rice/xinitrc"         "$HOME/.xinitrc"
  cp -raf "$DIR/../../../rice/base-i3-config"  "$HOME/.Xresources"
  cp -raf "$DIR/../../../rice/base-Xresources" "$HOME/.Xresources"
  sudo cp "$HOME/.Xresources"                  "/root/.Xresources"
fi

while true; do
  read -p "Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      sudo zypper -n install --no-recommends curl wget vim python3-httpie lsof git tmux gedit
      sudo zypper -n install --no-recommends papirus-icon-theme
      sudo zypper -n install --no-recommends feh lxappearance xbacklight xrandr xrdb xinput
      sudo zypper -n install --no-recommends notification-daemon
      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      sudo zypper -n install --no-recommends alsa-utils libnotify-tools
      sudo zypper -n install --no-recommends pulseaudio pulseaudio-utils pavucontrol

      # MANUAL 3b4f8b3: PulseAudio Applet. Some are already installed
      sudo zypper -n install --no-recommends gtk3-branding-openSUSE libnotify4 libpulse0

      sudo zypper -n install --no-recommends glib2-devel gtk3-devel libnotify-devel
      sudo zypper -n install --no-recommends libpulse-devel libX11-devel
      sudo zypper -n install --no-recommends autoconf automake pkgconf

      git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
      cd pa-applet && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag
      git tag -f "git-$(git rev-parse --short HEAD)"
      ./autogen.sh && ./configure && make && sudo make install
      cd /tmp

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      sudo zypper -n install --no-recommends NetworkManager-branding-openSUSE NetworkManager-applet
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

      sudo zypper -n install --no-recommends neofetch
      sudo zypper -n install --no-recommends gtk2-branding-openSUSE gtk3-branding-openSUSE

      sudo zypper -n install --no-recommends breeze5-cursors
      sudo ln -s /usr/share/icons/breeze_cursors /usr/share/icons/Breeze
      sudo zypper -n install --no-recommends dbus-1-x11 dunst conky compton w3m
      sudo zypper -n install --no-recommends ffmpegthumbnailer

      sudo zypper -n install --no-recommends python3-pip

      # https://pillow.readthedocs.io/en/stable/installation.html
      sudo zypper -n install --no-recommends libjpeg62
      sudo zypper -n install --no-recommends python3-devel libjpeg62-devel zlib-devel libXext-devel
      sudo pip3 install ueberzug
      sudo zypper -n install --no-recommends poppler-tools
      sudo zypper -n install --no-recommends mediainfo
      sudo zypper -n install --no-recommends transmission transmission-common
      sudo zypper -n install --no-recommends zip unzip tar xz unrar
      sudo zypper -n install --no-recommends odt2txt

      # MANUAL 2.12.c: i3lock-color. Some are already installed
      sudo zypper -n remove i3lock
      sudo zypper -n install --no-recommends libcairo2 libev4 libjpeg-turbo libxcb1 libxkbcommon0
      sudo zypper -n install --no-recommends libxkbcommon-x11-0 libxcb-image0 pkgconf

      sudo zypper -n install --no-recommends cairo-devel libev-devel libjpeg62-devel libxkbcommon-x11-devel
      sudo zypper -n install --no-recommends pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel autoconf automake

      git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
      cd i3lock-color && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag

      git tag -f "git-$(git rev-parse --short HEAD)"
      autoreconf -fi && ./configure && make && sudo make install
      echo "auth include system-auth" | sudo tee /etc/pam.d/i3lock
      cd /tmp

      # terminal-based file viewer
      sudo zypper -n install --no-recommends ranger
      sudo zypper -n install --no-recommends vifm

      # requirements for ranger [scope.sh]
      sudo zypper -n install --no-recommends file libcaca0 python3-Pygments atool libarchive13 unrar lynx
      sudo zypper -n install --no-recommends mupdf transmission transmission-common mediainfo odt2txt python3-chardet

      # i3wm customization, dmenu replacement, i3status replacement
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

      # MANUAL 3.3.1: polybar
      sudo zypper -n install --no-recommends libcairo2 libxcb-cursor0 libxcb-image0 libxcb-ewmh2 libxcb-xrm0
      sudo zypper -n install --no-recommends alsa curl libjsoncpp19 libmpdclient2 libpulse0 libnl3-200 wireless-tools

      sudo zypper -n install --no-recommends cairo-devel xcb-proto-devel xcb-util-devel xcb-util-cursor-devel xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel
      sudo zypper -n install --no-recommends alsa-devel libcurl-devel jsoncpp-devel libmpdclient-devel libpulse-devel libnl3-devel cmake libiw-devel
      sudo zypper -n install --no-recommends i3-gaps-devel python-xml gcc-c++ gcc python git pkgconf

      git clone --recurse-submodules https://github.com/jaagr/polybar.git
      cd polybar && git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      [ ${#tag} -ge 1 ] && git checkout $tag
      git tag -f "git-$(git rev-parse --short HEAD)"
      rm -rf build/ && mkdir -p build && cd build/
      cmake .. && make -j$(nproc) && sudo make install
      cd /tmp

      sudo zypper -n install --no-recommends scrot

      sudo zypper -n install --no-recommends accountsservice

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


