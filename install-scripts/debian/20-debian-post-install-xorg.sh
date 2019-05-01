#!/bin/bash
# NOTE this script is only tested in my machines
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$os" = "debian" ]; then
  while true; do
    echo "
If sudo is not enabled during installation (Debian). Logout this user, login as root on
tty2 (Ctrl + Alt + F2) then execute the commands below before proceeding.

apt install -y sudo libuser
groupadd wheel
usermod -aG wheel $(whoami)
usermod -aG sudo $(whoami)
usermod -g wheel $(whoami)
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers
"
  read -p "Choose action: [l]ogout | [s]kip   " isu
  case $isu in
      [Ss]* ) break;;
      [Ll]* ) sudo pkill -KILL -u $(whoami);;
      * ) echo "Invalid input";;
    esac
  done
fi

while true; do
  read -p "Will boot with other linux distros and share a partitions [yN]?   " wdb
  case $wdb in
    [Yy]* )
      while true; do
        echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
        read -p "Enter UID or [e]xit:   " uid
        case $uid in
          [Ee]* ) break;;
          * )
            while true; do
              echo "

NOTE: Use a GUID that will less likely be used as an ID by other distros (e.g. 1106).
This GUID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2 (Ctrl + Alt + F2):

groupadd wheel
usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Choose action: [l]ogout | [s]kip   " wultp
                    case $wultp in
                      [Ss]* ) break 4;;
                      [Ll]* ) sudo pkill -KILL -u $(whoami);;
                      * ) echo "Invalid input";;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* )
      break;;
    * )
      sudo chfn -f "$fn" $(whoami)
      break;;
  esac
done

sudo apt update
sudo apt -y upgrade

# xorg
sudo apt install -y xserver-xorg-core

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.
sudo apt install -y --no-install-recommends xinit

## XORG-APPS
# bdftopcf    - Font compiler for the X server and font server.
# mkfontdir   - Create an index of X font files in a directory.
# mkfontscale - Create an index of scalable font files for X.
sudo apt install -y xfonts-utils
# xbacklight - Adjust backlight brightness using RandR extension .
sudo apt install -y xbacklight
# xmodmap - Utility for modifying keymaps and pointer button mappings in X.
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
# xrdb    - X server resource database utility.
sudo apt install -y --no-install-recommends x11-xserver-utils
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
sudo apt install -y --no-install-recommends xinput
# xprop    - Property displayer for X.
# xdpyinfo - Display information utility.
sudo apt install -y --no-install-recommends x11-utils

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
sudo apt install -y --no-install-recommends xserver-xorg-input-libinput
sudo apt install -y --no-install-recommends xserver-xorg-input-kbd xserver-xorg-input-mouse

# Fallback GPU 
sudo apt install -y --no-install-recommends xserver-xorg-video-fbdev
sudo apt install -y --no-install-recommends xserver-xorg-video-vesa

# fonts
sudo apt install -y --no-install-recommends xfonts-75dpi xfonts-100dpi

#### DESKTOP ENV LIST
install_i3() {
  if [ -d /etc/gdm ]; then
    # use lightdm instead
    sudo systemctl disable gdm
  fi

  # Greeter
  sudo apt install -y --no-install-recommends lightdm
  sudo apt install -y --no-install-recommends fonts-noto
  sudo apt install -y --no-install-recommends lightdm-gtk-greeter
  sudo apt install -y --no-install-recommends lightdm-gtk-greeter-settings
  sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

  lightdmUnit='/usr/lib/systemd/system/lightdm.service'
  if [ -f /usr/lib/systemd/system/lightdm.service ]; then
    lightdmUnit='/usr/lib/systemd/system/lightdm.service'
  else
    if [ -f /etc/systemd/system/lightdm.service ]; then
      lightdmUnit='/etc/systemd/system/lightdm.service'
    fi
  fi

  # If lightdm unit doesnt exists it may be manage by other unit.
  # In ubuntu, ubuntu lets you pick your default display manager when lightdm is installed,
  # instead of settings a daemon
  if [ -f $lightdmUnit ]; then
    if cat $lightdmUnit | grep -q 'Alias=display-manager.service'; then
      echo 'Alias already exists'
    else
      if cat $lightdmUnit | grep -q '\[Install\]'; then
        echo 'Install already exists'
      else
        echo '[Install]' | sudo tee -a $lightdmUnit
      fi
  
      echo 'Alias=display-manager.service' | sudo tee -a $lightdmUnit
    fi
  fi

  sudo systemctl enable lightdm
  sudo systemctl set-default graphical.target

  # Install window tiling manager
  sudo apt install -y --no-install-recommends i3 i3status i3lock rxvt-unicode

  # File manager
  sudo apt install -y --no-install-recommends nautilus

  if [ ! -f "$HOME/.riced" ];then
    mkdir -p $HOME/.config
    mkdir -p $HOME/.config/i3

    # Fix default i3 config
    sudo cp /etc/i3/config $HOME/.config/i3/config
    sudo chown $(whoami):$(whoami) $HOME/.config/i3/config
  
    sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
    sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config
    sed -i 's/dmenu_run/dmenu/g' $HOME/.config/i3/config

    sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
    sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config
    sudo sed -i 's/dmenu_run/dmenu/g' /etc/i3/config
  
    cp -raf $DIR/../../rice/xinitrc $HOME/.xinitrc
    cp -raf "$DIR/../../rice/config-i3-base" "$HOME/.Xresources"
    sudo cp $HOME/.Xresources /root/.Xresources
  fi

  while true; do
    read -p "

Minimal installation done. Would you like to proceed [Yn]?   " yn
    case $yn in
      [Nn]* ) break;;
      * )

        # will use for manually installed packages, /tmp has limited space
        cd /tmp

        sudo apt install -y --no-install-recommends curl wget vim httpie lsof git tmux gedit

        # theme icon
        # git clone --recurse-submodules https://github.com/daniruiz/flat-remix.git
        # cd flat-remix
        # git fetch --tags
        # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
        # if [ ${#tag} -ge 1 ]; then
        #   git checkout $tag
        # fi
        # git tag -f "git-$(git rev-parse --short HEAD)"
        # sudo mkdir -p /usr/share/icons && sudo cp -raf Flat-Remix* /usr/share/icons/
        # sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix
        # cd /tmp
        sudo apt install -y --no-install-recommends papirus-icon-theme

        # display
        sudo apt install -y --no-install-recommends feh arandr lxappearance xbacklight x11-xserver-utils xinput

        # Generic notification
        # echo "
        # [D-BUS Service]
        # Name=org.freedesktop.Notifications
        # Exec=/usr/libexec/notification-daemon
        # " | sudo tee /usr/share/dbus-1/services/org.freedesktop.Notifications.service

        # # Xfce notification
        # echo "
        # [D-BUS Service]
        # Name=org.freedesktop.Notifications
        # Exec=/usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd
        # SystemdService=xfce4-notifyd.service
        # " | sudo tee /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service

        # Make sure other notification service exists to give way to dunst
        if [ -f /usr/share/dbus-1/services/org.freedesktop.Notifications.service ]; then
          sudo rm /usr/share/dbus-1/services/org.freedesktop.Notifications.service
        fi

        if [ -f /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service ]; then
          sudo rm /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
        fi

        # audio
        sudo apt install -y --no-install-recommends alsa-utils
        sudo apt install -y --no-install-recommends pulseaudio pulseaudio-utils pavucontrol

        amixer sset "Master" unmute
        amixer sset "Speaker" unmute
        amixer sset "Headphone" unmute
        amixer sset "Mic" unmute
        amixer sset "Mic Boost" unmute

        amixer sset "Master" 100%
        amixer sset "Speaker" 100%
        amixer sset "Headphone" 100%
        amixer sset "Mic" 100%
        amixer sset "Mic Boost" 100%

        # MANUAL 3b4f8b3: PulseAudio Applet. Some are already installed
        sudo apt install -y --no-install-recommends libglib2.0-dev libgtk-3-dev libnotify-dev
        sudo apt install -y --no-install-recommends libpulse-dev libx11-dev
        sudo apt install -y --no-install-recommends autoconf automake pkgconf

        sudo apt install -y --no-install-recommends libgtk-3-0 libnotify-bin libpulse0

        git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
        cd pa-applet

        git fetch --tags
        tag=$(git describe --tags `git rev-list --tags --max-count=1`)

        if [ ${#tag} -ge 1 ]; then
          git checkout $tag
        fi

        git tag -f "git-$(git rev-parse --short HEAD)"
        ./autogen.sh && ./configure && make && sudo make install
        cd /tmp

        sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
        sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

        # network manager
        sudo apt install -y --no-install-recommends network-manager network-manager-gnome
        sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
        sudo systemctl enable NetworkManager

        # fonts - fc-list
        # git clone https://github.com/ryanoasis/nerd-fonts.git
        # ./install
        wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
        wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
        wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
        wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

        sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
        sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
        sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
        sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
        sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"

        # terminal
        sudo apt install -y --no-install-recommends neofetch

        # gtk theme change
        sudo apt install -y --no-install-recommends gtk2-engines gtk2-engines-murrine libgtk2.0-0 libgtk-3-0

        # mouse cursor theme
        sudo apt install -y --no-install-recommends breeze-cursor-theme
        sudo ln -s /usr/share/icons/breeze_cursors /usr/share/icons/Breeze

        # notification, system monitor, compositor, image on terminal
        sudo apt install -y --no-install-recommends dbus-x11 dunst conky compton w3m
        sudo apt install -y --no-install-recommends ffmpegthumbnailer

        # for vifm
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
        cd i3lock-color

        git fetch --tags
        tag=$(git describe --tags `git rev-list --tags --max-count=1`)

        if [ ${#tag} -ge 1 ]; then
          git checkout $tag
        fi

        git tag -f "git-$(git rev-parse --short HEAD)"
        autoreconf -fi && ./configure && make && sudo make install
        echo "auth include login" | sudo tee /etc/pam.d/i3lock
        cd /tmp

        # terminal-based file viewer
        sudo apt install -y --no-install-recommends ranger
        sudo apt install -y --no-install-recommends vifm

        # requirements for ranger [scope.sh]
        sudo apt install -y --no-install-recommends file libcaca0 python3-pygments atool libarchive13 unrar lynx
        sudo apt install -y --no-install-recommends mupdf transmission-cli mediainfo odt2txt python3-chardet

        # i3wm customization, dmenu replacement, i3status replacement
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
        cd i3-gaps

        git fetch --tags
        tag=$(git describe --tags `git rev-list --tags --max-count=1`)

        if [ ${#tag} -ge 1 ]; then
          git checkout $tag
        fi

        git tag -f "git-$(git rev-parse --short HEAD)"
        autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/
        ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
        make && sudo make install

        cd /tmp

        # MANUAL 3.3.1: polybar
        sudo apt install -y --no-install-recommends libasound2-dev libcairo2-dev xcb-proto libxcb-util0-dev libxcb-cursor-dev libxcb-image0-dev libxcb-xrm-dev
        sudo apt install -y --no-install-recommends libcurl4-openssl-dev libjsoncpp-dev libmpdclient-dev libpulse-dev libnl-3-dev libiw-dev
        sudo apt install -y --no-install-recommends libxcb-composite0-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-randr0-dev
        sudo apt install -y --no-install-recommends g++ gcc python git pkgconf cmake

        sudo apt install -y --no-install-recommends libasound2 libasound2 alsa-tools libcairo2 libxcb-cursor0 libxcb-image0 libxcb-xrm0 libxcb-icccm4 libxcb-ewmh2 libxcb-composite0
        sudo apt install -y --no-install-recommends curl libjsoncpp1 libmpdclient2 libpulse0 libnl-3-200 wireless-tools python-xcbgen libxcb-randr0

        # ncmpcpp playlist
        # 1) go to browse
        # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
        # 3) press "A"
        #
        # r: repeat, z: shuffle, y: repeat one
        sudo apt install -y --no-install-recommends mpd mpc ncmpcpp
        sudo systemctl disable mpd
        sudo systemctl stop mpd

        git clone --recurse-submodules https://github.com/jaagr/polybar.git
        cd polybar

        git fetch --tags
        tag=$(git describe --tags `git rev-list --tags --max-count=1`)

        if [ ${#tag} -ge 1 ]; then
          git checkout $tag
        fi

        git tag -f "git-$(git rev-parse --short HEAD)"
        rm -rf build/ && mkdir -p build && cd build/
        cmake .. && make -j$(nproc) && sudo make install

        cd /tmp

        # popup calendar
        # sudo apt install -y --no-install-recommends xdotool yad
        sudo apt install -y --no-install-recommends scrot
        sudo apt install -y --no-install-recommends accountsservice

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

        echo "
[User]
Icon=/var/lib/AccountsService/icons/$user.png
XSession=i3
SystemAccount=false
" | sudo tee /var/lib/AccountsService/users/$user

        sudo cp $DIR/../../rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
        sudo cp $DIR/../../rice/images/avatar/default-user.png /usr/share/pixmaps/default-user.png
        sudo chown root:root /var/lib/AccountsService/users/$user
        sudo chown root:root /var/lib/AccountsService/icons/$user.png

        sudo chmod 644 /var/lib/AccountsService/users/$user
        sudo chmod 644 /var/lib/AccountsService/icons/$user.png

        # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
        bash $DIR/../../setup-scripts/update-libinput.sh

        echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/apt" | sudo tee -a "/etc/sudoers"

        if [ ! -f $HOME/.riced ];then
          bash $DIR/../../setup-scripts/setup-user-configs.sh
          bash $DIR/../../setup-scripts/update-scripts.sh
          touch $HOME/.riced
        fi

        # NOTE: needs adjustment for the sake of fedora
        sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

        mkdir -p "$HOME/.config/neofetch"
        cp -rf $DIR/../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf

        sudo mkdir -p /usr/share/icons/default
        echo "
[Icon Theme]
Inherits=Breeze
" | sudo tee /usr/share/icons/default/index.theme

        sudo mkdir -p /root/.vim
        sudo cp -raf $HOME/.vim/* /root/.vim
        sudo cp -raf $HOME/.vimrc /root/.vimrc

        sudo cp -rf $DIR/../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

        bash $DIR/../../setup-scripts/update-screen-detector.sh
        bash $DIR/../../setup-scripts/update-themes.sh

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
}

#### DESKTOP ENV INSTALL
if [ "$os" = "debian" ]; then
  while true; do
    echo "
If sudo is not enabled during installation (Debian). Logout this user, login as root on
tty2 (Ctrl + Alt + F2) then execute the commands below before proceeding.

apt install -y sudo libuser
groupadd wheel
usermod -aG wheel $(whoami)
usermod -aG sudo $(whoami)
usermod -g wheel $(whoami)
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers
"
  read -p "Choose action: [l]ogout | [s]kip   " isu
  case $isu in
      [Ss]* ) break;;
      [Ll]* ) sudo pkill -KILL -u $(whoami);;
      * ) echo "Invalid input";;
    esac
  done
fi

while true; do
  read -p "Will boot with other linux distros and share a partitions [yN]?   " wdb
  case $wdb in
    [Yy]* )
      while true; do
        echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
        read -p "Enter UID or [e]xit:   " uid
        case $uid in
          [Ee]* ) break;;
          * )
            while true; do
              echo "

NOTE: Use a GUID that will less likely be used as an ID by other distros (e.g. 1106).
This GUID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2 (Ctrl + Alt + F2):

groupadd wheel
usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Choose action: [l]ogout | [s]kip   " wultp
                    case $wultp in
                      [Ss]* ) break 4;;
                      [Ll]* ) sudo pkill -KILL -u $(whoami);;
                      * ) echo "Invalid input";;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* )
      break;;
    * )
      sudo chfn -f "$fn" $(whoami)
      break;;
  esac
done

if [ -d /sys/firmware/efi/efivars ] && sudo test ! -f "/boot/efi/startup.nsh"; then
  sudo mkdir -p /boot/efi/EFI/boot
  if [ -d "/boot/efi/EFI/refind" ]; then
    sudo cp -a /boot/efi/EFI/refind/refind_x64.efi /boot/efi/EFI/boot/bootx64.efi
  elif [ -d "/boot/efi/EFI/grub" ]; then
    sudo cp -a /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  elif [ -d "/boot/efi/EFI/GRUB" ]; then
    sudo cp -a /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  else
    sudo cp -a /boot/efi/EFI/$os/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  fi

  echo "bcf boot add 1 fs0:\\EFI\\boot\\bootx64.efi \"Fallback Bootloader\"
exit" | sudo tee /boot/efi/startup.nsh
fi

# fonts
if [ ! -f /etc/X11/xorg.conf ];then
  sudo touch /etc/X11/xorg.conf;
fi

# Font DIRS for X.org
sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

sudo dpkg --add-architecture i386
if [ "$os" = "debian" ]; then
  if cat /etc/apt/sources.list | grep -q "main contrib non-free"; then
    echo "Non-free repos already added."
  else
    sudo sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
    echo "Non-free repos added."
  fi
fi

sudo apt update
sudo apt -y upgrade

# non-free kernel drivers for debian
if [ "$os" = "debian" ]; then
  sudo apt install -y --no-install-recommends firmware-linux-nonfree
fi

sudo apt install -y build-essential linux-headers-$(uname -r) git
sudo apt install -y --no-install-recommends autoconf automake cmake make dkms pkgconf man-db psmisc
sudo apt install -y --no-install-recommends policykit-1-gnome

sudo apt install -y --no-install-recommends at
sudo systemctl enable atd
sudo systemctl start atd

# Sound
sudo apt install -y --no-install-recommends alsa-utils

# Gstreamer
sudo apt install -y --no-install-recommends gstreamer1.0-x gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-vaapi
sudo apt install -y --no-install-recommends gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

sudo apt install -y --no-install-recommends openjdk-11-jdk
sudo apt install -y browser-plugin-freshplayer-pepperflash

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* )
      sudo apt install -y --no-install-recommends intel-microcode
      break;;
    [Aa]* )
      sudo apt install -y --no-install-recommends amd64-microcode
      break;;
    * ) echo Invalid input
  esac
done

## GPU DRIVERS
generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

install_mesa_vulkan_drivers() {

  sudo apt install -y --no-install-recommends libd3dadapter9-mesa:amd64
  sudo apt install -y --no-install-recommends libegl-mesa0:amd64
  sudo apt install -y --no-install-recommends libgbm1:amd64
  sudo apt install -y --no-install-recommends libgl1-mesa-dri:amd64
  sudo apt install -y --no-install-recommends libglapi-mesa:amd64
  sudo apt install -y --no-install-recommends libglu1-mesa:amd64
  sudo apt install -y --no-install-recommends libglw1-mesa:amd64
  sudo apt install -y --no-install-recommends libglx-mesa0:amd64
  sudo apt install -y --no-install-recommends libosmesa6:amd64
  sudo apt install -y --no-install-recommends mesa-opencl-icd:amd64
  sudo apt install -y --no-install-recommends mesa-utils:amd64
  sudo apt install -y --no-install-recommends mesa-utils-extra:amd64

  sudo apt install -y --no-install-recommends libd3dadapter9-mesa:i386
  sudo apt install -y --no-install-recommends libegl-mesa0:i386
  sudo apt install -y --no-install-recommends libgbm1:i386
  sudo apt install -y --no-install-recommends libgl1-mesa-dri:i386
  sudo apt install -y --no-install-recommends libglapi-mesa:i386
  sudo apt install -y --no-install-recommends libglu1-mesa:i386
  sudo apt install -y --no-install-recommends libglw1-mesa:i386
  sudo apt install -y --no-install-recommends libglx-mesa0:i386
  sudo apt install -y --no-install-recommends libosmesa6:i386
  sudo apt install -y --no-install-recommends mesa-opencl-icd:i386
  sudo apt install -y --no-install-recommends mesa-utils:i386
  sudo apt install -y --no-install-recommends mesa-utils-extra:i386

  sudo apt install -y --no-install-recommends mesa-vulkan-drivers:amd64
  sudo apt install -y --no-install-recommends libvulkan1:amd64
  sudo apt install -y --no-install-recommends libva-glx2:amd64

  sudo apt install -y --no-install-recommends mesa-vulkan-drivers:i386
  sudo apt install -y --no-install-recommends libvulkan1:i386
  sudo apt install -y --no-install-recommends libva-glx2:i386

  sudo apt install -y --no-install-recommends vulkan-utils
}

while true; do
  read -p "

What GPU are you using?
  [i]ntel
  [a]md
  [n]vidia
  [v]m
  [e]xit

Enter GPU:   " gpui
  case $gpui in
    [Ee]* )
      break;;
    [Vv]* )
      break;;
    [Ii]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-intel
      install_mesa_vulkan_drivers

      sudo cp -raf "$DIR/../../system-confs/20-intel.conf" "/etc/X11/xorg.conf.d/20-intel.conf"
      echo Intel drivers installed;
      break;;
    [Aa]* )
      while true; do
        read -p "


What driver to use?
  Check: https://en.wikipedia.org/wiki/Template:AMD_graphics_API_support
  [1] AMDGPU    - GCN 3, GCN 4 and newer
  [2] ATI       - TeraScale 1, TeraScale 2, TeraScale 3, GCN 1, GCN 2
  [e]xit
  " amdd
        case $amdd in
          [1]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-amdgpu
            install_mesa_vulkan_drivers

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-ati
            install_mesa_vulkan_drivers

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      if [ "$os" != "debian" ]; then
        sudo apt install -y nvidia-driver-390
      else
        sudo apt install -y --no-install-recommends xserver-xorg-video-nvidia nvidia-detect nvidia-xconfig

        sudo apt install -y nvidia-driver:amd64
        sudo apt install -y libgl1-nvidia-glx:amd64

        sudo apt install -y nvidia-driver:i386
        sudo apt install -y libgl1-nvidia-glx:i386

        sudo apt install -y --no-install-recommends libvulkan1:amd64
        sudo apt install -y --no-install-recommends libva-glx2:amd64

        sudo apt install -y --no-install-recommends libvulkan1:i386
        sudo apt install -y --no-install-recommends libva-glx2:i386

        sudo apt install -y --no-install-recommends vulkan-utils

        generate_nvidia_gpu_config
        sudo nvidia-xconfig
      fi

      echo NVIDIA drivers installed;
      break;;
  esac
done

# Adding intel backlight
if ls /sys/class/backlight | grep -q "^intel_backlight$"; then
  if [ ! -d /etc/X11/xorg.conf.d ];then
    sudo mkdir -p /etc/X11/xorg.conf.d
  fi

  if [ !$(ls /etc/X11/xorg.conf.d | grep -q ^20-intel.conf$) ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backligaht"; then
    echo '
Section "Device"
  Identifier  "Card0"
  Driver      "intel"
  Option      "Backlight"  "intel_backlight"
EndSection
' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;
    echo Added intel_backlight;
  fi
fi

## Hardware acceleration drivers installation
sudo apt install -y --no-install-recommends mesa-va-drivers mesa-vdpau-drivers
sudo apt install -y --no-install-recommends libvdpau1 libvdpau-va-gl1

# Network
while true; do
  lspci -nnk | grep 0280 -A3
  read -p "


Wireless drivers installation:
If your driver is not listed, check:
https://wiki.archlinux.org/index.php/Wireless_network_configuration

[1] Show Network Controller
[2] Broadcom
[m] Modprobe a module
[e] Exit

Enter action:   " wd
  case $wd in
    [Ee]* ) break;;
    [Mm]* )
      while true; do
        read -p "Enter module:   " m
        case $m in
          * ) sudo modprobe -a $m; break;;
        esac
      done;;
    [1] ) lspci | grep Network;;
    [2] )
      sudo apt install -y --no-install-recommends linux-headers-$(uname -r) linux-image-$(uname -r);
      sudo apt install -y --no-install-recommends broadcom-sta-dkms wireless-tools;
      sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
      sudo modprobe wl
      echo "
Installation done...
";;
  esac
done

# TRRS
while true; do
  read -p "
Detect microphone plugged in a 4-pin 3.5mm (TRRS) jack [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        echo "
Devices:
"
        aplay --list-devices
        read -p "


Check your HD Audio model here:
https://dri.freedesktop.org/docs/drm/sound/hd-audio/models.html or
http://git.alsa-project.org/?p=alsa-kernel.git;a=blob;f=Documentation/sound/alsa/HD-Audio-Models.txt;hb=HEAD

Enter HD Audio Model (e.g. mbp101, macbook-pro, laptop-dmic etc) or [e]xit:   " hdam
        case $hdam in
          [Ee] ) break 2;;
          * )
            sudo touch /etc/modprobe.d/alsa-base.conf;
            echo "
options snd_hda_intel index=0
options snd_hda_intel model=$hdam" | sudo tee /etc/modprobe.d/alsa-base.conf
            break;;
        esac
      done;;
  esac
done

#### CHOOSE DESKTOP ENVIRONMENT
install_i3
