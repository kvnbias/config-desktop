

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

echo "
app-text/ghostscript-gpl unicode tiff
app-text/poppler cairo
dev-lang/python sqlite
dev-libs/glib dbus
dev-libs/libxml2 python
gnome-base/gvfs fuse policykit
media-libs/flac ogg
media-libs/gst-plugins-base opengl pango
media-libs/gst-plugins-bad opengl
media-libs/harfbuzz icu
media-libs/jasper opengl
media-libs/imlib2 mp3
media-libs/libcaca imlib opengl truetype
media-libs/libpng apng
media-libs/libwebp gif opengl
media-plugins/alsa-plugins ffmpeg oss
media-sound/pulseaudio bluetooth dbus sox equalizer native-headset
media-video/ffmpeg alsa bluray chromium fontconfig libass libcaca mp3 libv4l opengl svg v4l vaapi vdpau wavpack webp x264 x265
net-libs/webkit-gtk libnotify
net-print/cups usb dbus
net-print/cups-filters dbus tiff pdf zeroconf
net-wireless/bluez cups user-session
www-client/w3m unicode imlib
www-plugins/freshplayerplugin v4l vaapi vdpau
x11-libs/cairo opengl xcb
x11-libs/gdk-pixbuf tiff
x11-libs/gtk+ xinerama colord
x11-libs/libxcb xkb
x11-misc/lightdm-gtk-greeter branding
x11-terms/rxvt-unicode 256-color pixbuf xft unicode3 fading-colors
" | sudo tee /etc/portage/package.use/flags

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

# fonts
if [ ! -f /etc/X11/xorg.conf ];then
  sudo touch /etc/X11/xorg.conf;
fi

# Font DIRS for X.org
sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

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

install_packages "sys-kernel/linux-firmware sys-kernel/linux-headers"
install_packages "gnome-extra/polkit-gnome"


install_packages "sys-process/at"
sudo systemctl enable atd
sudo systemctl start atd

# Sound
install_packages "media-sound/alsa-utils"

# Gstreamer
install_packages "media-libs/gstreamer media-plugins/gst-plugins-libav media-plugins/gst-plugins-vaapi"
install_packages "media-libs/gst-plugins-base media-libs/gst-plugins-bad media-libs/gst-plugins-good media-libs/gst-plugins-ugly"

install_packages "dev-java/openjdk-bin"
install_packages "www-plugins/freshplayerplugin"

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* )
      install_packages "sys-firmware/intel-microcode"
      break;;
    [Aa]* ) break;;
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
      while true; do
        read -p "
Enter virtual machine:

[1] Virtualbox
[2] VMware
[e] Exit

Action:   " vma
        case $vma in
          [Ee] ) break;;
          1 ) install_packages "x11-drivers/xf86-video-vboxvideo"; break 2;;
          2 ) install_packages "x11-drivers/xf86-video-vmware"; break 2;;
        esac
      done;;
    [Ii]* )
      install_packages "x11-drivers/xf86-video-intel"
      install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

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
            install_packages "x11-drivers/xf86-video-amdgpu"
            install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            install_packages "x11-drivers/xf86-video-ati"
            install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      install_packages "x11-drivers/xf86-video-nv"
      install_packages "x11-drivers/nvidia-drivers media-libs/vulkan-loader dev-util/vulkan-tools"

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

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backlight"; then
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
install_packages "x11-libs/libva-vdpau-driver x11-libs/libvdpau x11-misc/vdpauinfo"

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
      install_packages "net-wireless/broadcom-sta net-wireless/wireless-tools"
      sudo modprobe wl

      if [ -f /etc/modules-load.d/networking.conf ]; then
        echo 'wl' | sudo tee /etc/modules-load.d/networking.conf
      else
        echo 'wl' | sudo tee -a /etc/modules-load.d/networking.conf
      fi

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


if [ -d /etc/gdm ]; then
  # use lightdm instead
  sudo systemctl disable gdm
fi

# Greeter
install_packages "x11-misc/lightdm x11-misc/lightdm-gtk-greeter media-fonts/noto"
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# Install window tiling manager
install_packages "x11-wm/i3 x11-misc/i3status x11-misc/i3lock x11-misc/dmenu x11-terms/rxvt-unicode"

# File manager
install_packages "gnome-base/nautilus"

if [ ! -f "$HOME/.riced" ];then
  mkdir -p $HOME/.config
  mkdir -p $HOME/.config/i3

  # Fix default i3 config
  sudo cp /etc/i3/config $HOME/.config/i3/config
  sudo chown $(whoami):wheel $HOME/.config/i3/config

  sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
  sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config

  sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
  sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config

  cp -raf $DIR/../../rice/xinitrc $HOME/.xinitrc
  cp -raf "$DIR/../../rice/config-i3-base" "$HOME/.Xresources"
  sudo cp $HOME/.Xresources /root/.Xresources
fi

echo "
[User]
Icon=/home/$(whoami)/.face
XSession=i3
SystemAccount=false
" | sudo tee /var/lib/AccountsService/users/$(whoami)

while true; do
  read -p "

Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      echo "
app-admin/conky wifi
app-misc/vifm vim vim-syntax
lxde-base/lxappearance dbus
media-gfx/feh xinerama curl
media-gfx/imagemagick corefonts fontconfig graphviz pango hdri svg tiff webp xml
media-sound/alsa gstreamer oss
media-sound/mpd flac lame libmpdclient pulseaudio sqlite
media-sound/ncmpcpp visualizer outputs taglib clock icu
media-video/libmediainfo curl
media-video/mediainfo curl
net-misc/curl http2 ssh
net-misc/modemmanager policykit
net-misc/networkmanager dhcpcd wifi bluetooth connection-sharing policykit -resolvconf
sys-process/lsof rpc
x11-misc/compton dbus opengl xinerama
x11-misc/dunst dunstify
x11-misc/polybar alsa curl i3wm ipc mpd network
x11-misc/rofi windowmode
" | sudo tee -a /etc/portage/package.use/flags

      sudo mkdir -p /usr/local/portage/{metadata,profiles}
      sudo chown -R portage:portage /usr/local/portage
      echo 'local' | sudo tee /usr/local/portage/profiles/local

      echo "
masters = gentoo
auto-sync = false
" | sudo tee /usr/local/portage/metadata/layout.conf

      echo "
[local]
location = /usr/local/portage
" | sudo tee /etc/portage/repos.conf/local.conf

      install_packages "net-misc/curl net-misc/wget net-misc/httpie sys-process/lsof dev-vcs/git app-misc/tmux app-editors/vim app-editors/gedit"
      install_packages "app-portage/repoman"

      # MANUAL: papirus-icon-theme 20190331
      # wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sh
      add_ebuild "x11-themes" "papirus-icon-theme" "$DIR/ebuilds/papirus-icon-theme-20190331.ebuild"
      install_packages "x11-themes/papirus-icon-theme"

      # display
      install_packages "media-libs/imlib2"
      install_packages "media-gfx/feh x11-misc/arandr lxde-base/lxappearance"
      install_packages "x11-apps/xbacklight x11-apps/xrandr x11-apps/xrdb x11-apps/xinput"

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
      install_packages "media-sound/alsa-utils media-sound/alsa-tools media-libs/alsa-lib"
      install_packages "media-sound/pulseaudio media-sound/pavucontrol"

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

      # MANUAL pa-applet 20181009
      # install_packages "dev-libs/glib x11-libs/libnotify x11-libs/libX11"
      # install_packages "sys-devel/autoconf sys-devel/automake dev-util/pkgconf"
      #
      # git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
      # cd pa-applet && git fetch --tags
      # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      # [ ${#tag} -ge 1 ] && git checkout $tag
      # git tag -f "git-$(git rev-parse --short HEAD)"
      # ./autogen.sh && ./configure && make && sudo make install
      add_ebuild "x11-misc" "pa-applet" "$DIR/ebuilds/pa-applet-20181009.ebuild"
      install_packages "x11-misc/pa-applet"

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      # network manager
      install_packages "net-misc/networkmanager gnome-extra/nm-applet"
      sudo systemctl enable NetworkManager

      # MANUAL: fonts - fc-list
      # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
      # wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
      #
      # sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
      # sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
      # sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
      # sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
      # sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"
      add_ebuild "media-fonts" "nerd-fonts" "$DIR/ebuilds/nerd-fonts-2.0.0.ebuild"
      install_packages "media-fonts/nerd-fonts"

      # terminal
      install_packages "app-misc/neofetch"

      # MANUAL: breeze-xcursors 5.15.4.1
      # git clone https://github.com/KDE/breeze.git /tmp/breeze
      # cd /tmp/breeze/cursors/Breeze
      #
      # git fetch --tags
      # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      # [ ${#tag} -ge 1 ] && git checkout $tag
      # git tag -f "git-$(git rev-parse --short HEAD)"
      # sudo cp -raf /tmp/breeze/cursors/Breeze/Breeze /usr/share/icons/Breeze
      add_ebuild "x11-themes" "breeze-xcursors" "$DIR/ebuilds/breeze-xcursors-5.15.4.1.ebuild"
      install_packages "x11-themes/breeze-xcursors"

      # system monitor, compositor, image on terminal
      install_packages "x11-misc/dunst app-admin/conky x11-misc/compton www-client/w3m"
      install_packages "media-video/ffmpegthumbnailer"

      # for vifm
      # https://pillow.readthedocs.io/en/stable/installation.html
      install_packages "dev-python/pip"
      install_packages "app-text/poppler media-video/mediainfo net-p2p/transmission"
      install_packages "app-arch/zip app-arch/unzip app-arch/tar app-arch/xz-utils app-arch/unrar"
      install_packages "app-text/catdoc app-text/docx2txt"

      install_packages "media-libs/libjpeg-turbo sys-libs/zlib"
      install_packages "x11-libs/libXext dev-python/setuptools"
      pip3 install --user ueberzug

      # MANUAL i3lock-color 2.12.c
      sudo emerge --ask --verbose --depclean x11-misc/i3lock

      # install_packages "media-libs/libjpeg-turbo x11-libs/libxcb x11-libs/cairo dev-libs/libev x11-libs/libxkbcommon"
      # install_packages "x11-libs/xcb-util x11-libs/xcb-util-image x11-libs/xcb-util-xrm"
      # install_packages "sys-devel/autoconf sys-devel/automake"
      # git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
      # cd i3lock-color && git fetch --tags
      # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
      # [ ${#tag} -ge 1 ] && git checkout $tag
      #
      # git tag -f "git-$(git rev-parse --short HEAD)"
      # autoreconf -fi && ./configure && make && sudo make install
      add_ebuild "x11-misc" "i3lock-color" "$DIR/ebuilds/i3lock-color-2.12.ebuild"
      install_packages "x11-misc/i3lock-color"

      # terminal-based file viewer
      install_packages "app-misc/ranger app-misc/vifm"

      # requirements for ranger [scope.sh]
      install_packages "sys-apps/file media-libs/libcaca dev-python/pygments app-arch/atool app-arch/libarchive app-arch/unrar www-client/lynx"
      install_packages "app-text/mupdf net-p2p/transmission media-video/mediainfo app-text/odt2txt dev-python/chardet"

      # i3wm customization, dmenu replacement, i3status replacement
      sudo emerge --ask --verbose --depclean x11-wm/i3
      install_packages "x11-misc/rofi x11-wm/i3-gaps x11-misc/polybar"

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      install_packages "media-sound/mpd media-sound/mpc media-sound/ncmpcpp"
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      install_packages "media-gfx/scrot sys-apps/accountsservice"

      sudo emerge --ask --depclean

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

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/emerge" | sudo tee -a "/etc/sudoers"

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



