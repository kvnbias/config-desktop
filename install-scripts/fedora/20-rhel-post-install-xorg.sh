
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

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
  read -p "Would you like to update the host file [yN]?   " updh
  case $updh in
    [Yy]* )
      echo "
# ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4

127.0.0.1   localhost
::1         localhost
127.0.0.1   fedora.localdomain fedora
" | sudo tee /etc/hosts
      break;;
    * ) break;;
  esac
done

if cat /etc/default/grub | grep -q "GRUB_CMDLINE_LINUX=\".*rhgb.*\""; then
  sudo sed -i "s/rhgb//g" /etc/default/grub
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

if [ "$os" = "fedora" ]; then
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
else
  sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
fi

sudo dnf -y upgrade
echo 'metadata_expire=86400' | sudo tee -a /etc/dnf/dnf.conf

# xorg
sudo dnf install -y xorg-x11-server-Xorg --releasever=$fedver

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.
sudo dnf install -y xorg-x11-xinit --releasever=$fedver

## XORG-APPS
# bdftopcf    - Font compiler for the X server and font server.
# mkfontdir   - Create an index of X font files in a directory.
# mkfontscale - Create an index of scalable font files for X.
# xdpyinfo    - Display information utility.
sudo dnf install -y xorg-x11-font-utils --releasever=$fedver
# xbacklight - Adjust backlight brightness using RandR extension .
sudo dnf install -y xbacklight --releasever=$fedver
# xmodmap - Utility for modifying keymaps and pointer button mappings in X.
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
# xrdb    - X server resource database utility.
sudo dnf install -y xorg-x11-server-utils --releasever=$fedver
# xprop - Property displayer for X.
sudo dnf install -y xorg-x11-utils --releasever=$fedver

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
sudo dnf install -y libinput xorg-x11-drv-libinput --releasever=$fedver

# Fallback GPU 
sudo dnf install -y xorg-x11-drv-fbdev --releasever=$fedver
sudo dnf install -y xorg-x11-drv-vesa --releasever=$fedver

# fonts
sudo dnf install -y xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi --releasever=$fedver

#### DESKTOP ENV LIST
install_i3() {
  if [ -d /etc/gdm ]; then
    # use lightdm instead
    sudo systemctl disable gdm
  fi
 
  # Greeter
  # sudo dnf install -y lightdm --releasever=$fedver
  sudo dnf install -y google-noto-sans-fonts google-noto-fonts-common --releasever=$fedver
  sudo dnf install -y lightdm-gtk --releasever=$fedver
  sudo dnf install -y lightdm-gtk-greeter-settings --releasever=$fedver
  sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

  sudo systemctl enable lightdm
  sudo systemctl set-default graphical.target

  # Install window tiling manager
  sudo dnf install -y dmenu i3 i3status i3lock rxvt-unicode-256color-ml --releasever=$fedver

  # File manager
  sudo dnf install -y nautilus --releasever=$fedver

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
        sudo dnf install -y gcc make bash coreutils diffutils --releasever=$fedver
        sudo dnf install -y python rpm-build rpm-devel rpmlint patch rpmdevtools --releasever=$fedver
        rpmdev-setuptree
        sed -i "s~\$HOME~$DIR\/specs~g" /home/$(whoami)/.rpmmacros
        rm -rf /home/$(whoami)/rpmbuild

        sudo dnf install -y curl wget vim-minimal vim-enhanced httpie lsof git tmux gedit --releasever=$fedver

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
        sudo dnf install -y papirus-icon-theme --releasever=$fedver

        # display
        sudo dnf install -y feh arandr lxappearance xbacklight xorg-x11-server-utils --releasever=$fedver

        # package manager
        # sudo dnf install -y dnfdragora dnfdragora-updater --releasever=$fedver
        sudo dnf install -y notification-daemon --releasever=$fedver

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
        sudo dnf install -y alsa-utils --releasever=$fedver
        sudo dnf install -y pulseaudio pulseaudio-utils pavucontrol --releasever=$fedver

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
        # sudo dnf install -y glib2-devel gtk3-devel libnotify-devel --releasever=$fedver
        # sudo dnf install -y pulseaudio-libs-devel libX11-devel --releasever=$fedver
        # sudo dnf install -y autoconf automake pkgconf --releasever=$fedver
        # sudo dnf mark install gtk3 libnotify pulseaudio-libs pulseaudio-libs-glib2
        # git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
        # cd pa-applet && git fetch --tags
        # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
        # [ ${#tag} -ge 1 ] && git checkout $tag
        # git tag -f "git-$(git rev-parse --short HEAD)"
        # ./autogen.sh && ./configure && make && sudo make install
        sudo dnf builddep -y specs/i3lock-color.spec && rpmbuild -ba specs/pa-applet.spec
        sudo dnf install -y specs/rpmbuild/RPMS/x86_64/pa-applet-20181009-1.fc$fedver.x86_64.rpm

        sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
        sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

        # network manager
        sudo dnf install -y NetworkManager network-manager-applet --releasever=$fedver
        sudo systemctl enable NetworkManager

        # fonts - fc-list
        # git clone https://github.com/ryanoasis/nerd-fonts.git
        # ./install
        #
        # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
        # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
        # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
        # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
        # sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
        # sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
        # sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
        # sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
        # sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"
        rpmbuild -ba specs/nerd-fonts.spec
        sudo dnf install -y specs/rpmbuild/RPMS/x86_64/nerd-fonts-2.0.0-1.fc$fedver.x86_64.rpm

        # terminal
        sudo dnf install -y neofetch --releasever=$fedver

        # gtk theme change
        sudo dnf install -y gtk2 gtk3 --releasever=$fedver

        # mouse cursor theme
        sudo dnf install -y breeze-cursor-theme --releasever=$fedver
        sudo ln -s /usr/share/icons/breeze_cursors /usr/share/icons/Breeze

        # notification, system monitor, compositor, image on terminal
        sudo dnf install -y dunst conky compton w3m --releasever=$fedver
        sudo dnf install -y ffmpegthumbnailer --releasever=$fedver

        # for vifm
        sudo dnf install -y python3-pip --releasever=$fedver
        sudo dnf install -y redhat-rpm-config --releasever=$fedver

        # https://pillow.readthedocs.io/en/stable/installation.html
        sudo dnf install -y python3-devel libjpeg-turbo-devel zlib-devel libXext-devel --releasever=$fedver
        sudo pip3 install ueberzug --releasever=$fedver
        sudo dnf install -y poppler-utils --releasever=$fedver
        sudo dnf install -y mediainfo --releasever=$fedver
        sudo dnf install -y transmission-cli transmission-common --releasever=$fedver
        sudo dnf install -y zip unzip tar xz-libs unrar --releasever=$fedver
        sudo dnf install -y catdoc odt2txt --releasever=$fedver

        # MANUAL 2.12.c: i3lock-color. Some are already installed
        sudo dnf remove -y i3lock
        # sudo dnf install -y cairo-devel libev-devel libjpeg-devel libxkbcommon-x11-devel --releasever=$fedver
        # sudo dnf install -y pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel autoconf automake --releasever=$fedver
        #
        # sudo dnf install -y cairo libev libjpeg-turbo libxcb libxkbcommon --releasever=$fedver
        # sudo dnf install -y libxkbcommon-x11 xcb-util-image pkgconf --releasever=$fedver
        # sudo dnf mark install cairo libev libjpeg-turbo libxcb libxkbcommon libxkbcommon-x11 xcb-util-image
        #
        # git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
        # cd i3lock-color && git fetch --tags
        # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
        # [ ${#tag} -ge 1 ] && git checkout $tag
        # git tag -f "git-$(git rev-parse --short HEAD)"
        # autoreconf -fi && ./configure && make && sudo make install
        # echo "auth include system-auth" | sudo tee /etc/pam.d/i3lock
        spectool -g -R specs/i3lock-color.spec && sudo dnf builddep -y specs/i3lock-color.spec && rpmbuild -ba specs/i3lock-color.spec
        sudo dnf install -y specs/rpmbuild/RPMS/x86_64/i3lock-color-2.12.c-1.fc$fedver.x86_64.rpm

        # terminal-based file viewer
        sudo dnf install -y ranger --releasever=$fedver
        sudo dnf install -y vifm --releasever=$fedver

        # requirements for ranger [scope.sh]
        sudo dnf install -y file libcaca python3-pygments atool libarchive unrar lynx --releasever=$fedver
        sudo dnf install -y mupdf transmission-cli mediainfo odt2txt python3-chardet --releasever=$fedver

        # i3wm customization, dmenu replacement, i3status replacement
        sudo dnf install -y rofi --releasever=$fedver

        # MANUAL 4.16.1: i3-gaps
        sudo dnf remove -y i3
        # sudo dnf install -y libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel --releasever=$fedver
        # sudo dnf install -y xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel --releasever=$fedver
        # sudo dnf install -y libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel --releasever=$fedver
        # sudo dnf install -y pcre-devel pango-devel automake git gcc --releasever=$fedver
        #
        # sudo dnf install -y libev libxkbcommon-x11 perl pango startup-notification --releasever=$fedver
        # sudo dnf install -y xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl --releasever=$fedver
        #
        # sudo dnf mark install libev libxkbcommon-x11 perl pango startup-notification xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl
        #
        # git clone --recurse-submodules https://github.com/Airblader/i3.git i3-gaps
        # cd i3-gaps && git fetch --tags
        # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
        # [ ${#tag} -ge 1 ] && git checkout $tag
        #
        # git tag -f "git-$(git rev-parse --short HEAD)"
        # autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/ && ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
        # make && sudo make install
        spectool -g -R specs/i3-gaps.spec && sudo dnf builddep -y specs/i3-gaps.spec && rpmbuild -ba specs/i3-gaps.spec
        sudo dnf install -y specs/rpmbuild/RPMS/x86_64/i3-gaps-4.16.1-1.fc$fedver.x86_64.rpm

        # MANUAL 3.3.1: polybar
        sudo dnf install -y cairo-devel xcb-proto xcb-util-devel xcb-util-cursor-devel xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel --releasever=$fedver
        sudo dnf install -y alsa-lib-devel libcurl-devel jsoncpp-devel libmpdclient-devel pulseaudio-libs-devel libnl3-devel cmake wireless-tools-devel --releasever=$fedver
        sudo dnf install -y gcc-c++ gcc python python2 git pkgconf --releasever=$fedver

        sudo dnf install -y cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm --releasever=$fedver
        sudo dnf install -y alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools --releasever=$fedver

        # ncmpcpp playlist
        # 1) go to browse
        # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
        # 3) press "A"
        #
        # r: repeat, z: shuffle, y: repeat one
        sudo dnf install -y mpd mpc ncmpcpp --releasever=$fedver
        sudo systemctl disable mpd
        sudo systemctl stop mpd

        sudo dnf mark install cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm
        sudo dnf mark install alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools
        sudo dnf mark install mpd mpc ncmpcpp

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
        # sudo dnf install -y xdotool yad --releasever=$fedver

        sudo dnf install -y scrot --releasever=$fedver

        sudo dnf install -y accountsservice --releasever=$fedver

        sudo dnf remove -y alsa-lib-devel cairo-devel glib2-devel gtk3-devel jsoncpp-devel \
          libcurl-devel libev-devel libjpeg-devel libjpeg-turbo-devel libmpdclient-devel \
          libnl3-devel libnotify-devel libX11-devel libxcb-devel libXext-devel libXinerama-devel \
          libxkbcommon-devel libxkbcommon-x11-devel libXrandr-devel pam-devel pango-devel pcre-devel \
          pulseaudio-libs-devel python3-devel startup-notification-devel wireless-tools-devel xcb-proto \
          xcb-util-cursor-devel xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-wm-devel \
          xcb-util-xrm-devel yajl-devel zlib-devel
        sudo dnf -y autoremove

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

        echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/dnf" | sudo tee -a "/etc/sudoers"

        if [ ! -f $HOME/.riced ];then
          bash $DIR/../../setup-scripts/setup-user-configs.sh
          bash $DIR/../../setup-scripts/update-scripts.sh
          touch $HOME/.riced
        fi

        cd $mainCWD

        # sed -i "s/# exec --no-startup-id dnfdragora-updater/exec --no-startup-id dnfdragora-updater/g" $HOME/.config/i3/config
        # sed -i "s/# for_window \[class=\"Dnfdragora-updater\"\]/for_window [class=\"Dnfdragora-updater\"]/g" $HOME/.config/i3/config

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

        bash $DIR/../../setup-scripts/update-scripts.sh
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

#### PREP DESKTOP ENV
if [ -d /sys/firmware/efi/efivars ] && sudo test -d /boot/efi/EFI && sudo test ! -f /boot/efi/startup.nsh; then
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

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

# selinux utils
sudo dnf install -y checkpolicy policycoreutils-python-utils util-linux-user --releasever=$fedver
sudo dnf install -y libuser gcc gcc-c++ autoconf automake cmake make dkms pkgconfig bzip2 --releasever=$fedver

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

sudo dnf install -y at
sudo systemctl enable atd
sudo systemctl start atd

sudo dnf -y upgrade
sudo dnf install -y polkit-gnome --releasever=$fedver

# Sound
sudo dnf install -y alsa-utils --releasever=$fedver

# Gstreamer
sudo dnf install -y gstreamer1 gstreamer1-libav gstreamer1-vaapi --releasever=$fedver
sudo dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-base gstreamer1-plugins-good-gtk gstreamer1-plugins-good --releasever=$fedver
sudo dnf install -y gstreamer1-plugins-bad-nonfree gstreamer1-plugins-good-extras gstreamer1-plugins-bad-free-extras --releasever=$fedver
sudo dnf install -y gstreamer1-plugins-ugly-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools --releasever=$fedver

# Flash Repo
sudo dnf install -y http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
sudo dnf update

sudo dnf install -y java-openjdk flash-plugin flash-player-ppapi --releasever=$fedver

# upgrading:
# sudo dnf system-upgrade download --releasever=$fedver
# sudo dnf system-upgrade reboot
sudo dnf install -y dnf-plugin-system-upgrade

## GPU DRIVERS
generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub2-mkconfig -o /boot/grub2/grub.cfg; break 2;;
      esac
    done
  fi
}

install_mesa_vulkan_drivers() {

  sudo dnf install -y mesa-dri-drivers.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-filesystem.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libd3d.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libEGL.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libgbm.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libGL.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libglapi.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libGLES.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libGLU.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libGLw.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libOpenCL.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libOSMesa.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-libxatracker.x86_64 --releasever=$fedver

  sudo dnf install -y mesa-dri-drivers.i686 --releasever=$fedver
  sudo dnf install -y mesa-filesystem.i686 --releasever=$fedver
  sudo dnf install -y mesa-libd3d.i686 --releasever=$fedver
  sudo dnf install -y mesa-libEGL.i686 --releasever=$fedver
  sudo dnf install -y mesa-libgbm.i686 --releasever=$fedver
  sudo dnf install -y mesa-libGL.i686 --releasever=$fedver
  sudo dnf install -y mesa-libglapi.i686 --releasever=$fedver
  sudo dnf install -y mesa-libGLES.i686 --releasever=$fedver
  sudo dnf install -y mesa-libGLU.i686 --releasever=$fedver
  sudo dnf install -y mesa-libGLw.i686 --releasever=$fedver
  sudo dnf install -y mesa-libOpenCL.i686 --releasever=$fedver
  sudo dnf install -y mesa-libOSMesa.i686 --releasever=$fedver
  sudo dnf install -y mesa-libxatracker.i686 --releasever=$fedver

  sudo dnf install -y vulkan-loader.x86_64 --releasever=$fedver
  sudo dnf install -y mesa-vulkan-drivers.x86_64 --releasever=$fedver

  sudo dnf install -y vulkan-loader.i686 --releasever=$fedver
  sudo dnf install -y mesa-vulkan-drivers.i686 --releasever=$fedver
  
  sudo dnf install -y vulkan-tools.x86_64 --releasever=$fedver
}

while true; do
  read -p "

What GPU are you using?
  [i]ntel
  [a]md
  [n]vidia
  [v]m
  [e]xit

Enter GPU   " gpui
  case $gpui in
    [Ee]* )
      break;;
    [Vv]* )
      break;;
    [Ii]* )
      sudo dnf install -y xorg-x11-drv-intel --releasever=$fedver
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
            sudo dnf install -y xorg-x11-drv-amdgpu --releasever=$fedver
            install_mesa_vulkan_drivers

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo dnf install -y xorg-x11-drv-ati --releasever=$fedver
            install_mesa_vulkan_drivers

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      sudo dnf install -y xorg-x11-drv-nvidia akmod-nvidia nvidia-xconfig --releasever=$fedver

      sudo dnf install -y vulkan-loader.x86_64 vulkan-tools.x86_64 --releasever=$fedver
      sudo dnf install -y vulkan-loader.i686 vulkan-tools.i686 --releasever=$fedver

      generate_nvidia_gpu_config
      sudo nvidia-xconfig
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
sudo dnf install -y mesa-vdpau-drivers --releasever=$fedver
sudo dnf install -y libva-vdpau-driver --releasever=$fedver

# Network
sudo dnf install -y kernel-devel --releasever=$fedver
sudo dnf mark install kernel-devel
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
      sudo dnf install -y NetworkManager-wifi broadcom-wl kmod-wl kernel-devel --releasever=$fedver;
      sudo akmods --force --kernel `uname -r` --akmod wl
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

#### INSTALL DESKTOP ENV
install_i3
