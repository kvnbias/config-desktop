

#!/bin/bash

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

# Font DIRS for X.org
sudo cp -raf "$(pwd)/system-confs/xorg.conf" "/etc/X11/xorg.conf"

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

# selinux utils
sudo zypper -n install --no-recommends libuser
sudo zypper -n install --no-recommends gcc gcc-c++ autoconf automake cmake make dkms bzip2
sudo zypper -n install --no-recommends pkgconf #note

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

sudo zypper -n install --no-recommends at
sudo systemctl enable atd
sudo systemctl start atd

sudo zypper -n update

# Sound
sudo zypper -n install --no-recommends alsa-utils

bash $(pwd)/scripts/change-packman-mirror.sh

hasPackman=false
if zypper ls | grep -q 'packman-essentials'; then
  hasPackman=true
fi

# Gstreamer
sudo zypper -n install --no-recommends gstreamer gstreamer-plugins-vaapi
sudo zypper -n install --no-recommends gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-good-extra
sudo zypper -n install --no-recommends gstreamer-plugins-good-gtk #note

if [ "$hasPackman" = true ]; then
  sudo zypper -n install --no-recommends libtwolame0 libass9 libmp3lame0 libdc1394-22 libzimg2 libdvdread4
  sudo zypper -n install --no-recommends libgsm1 liba52-0 libzvbi0 libmpeg2-0 libschroedinger-1_0-0 libcelt0-2
  sudo zypper -n install --no-recommends libmpg123-0 libbs2b0 libwebpmux2 libgme0 libopenjpeg1 libkate1 libvdpau1
  sudo zypper -n install --no-recommends libmpcdec5 libopenal1 libHalf23 libIex-2_2-23 libIlmImf-2_2-23 libSoundTouch0
  sudo zypper -n install --no-recommends libgraphene-1_0-0 liblilv-0-0 liblrdf2 libmjpegutils-2_0-0 libmms0
  sudo zypper -n install --no-recommends libmpeg2encpp-2_0-0 libmplex2-2_0-0 libneon27 libofa0 libsbc1 libspandsp2
  sudo zypper -n install --no-recommends libsrtp1 libwebrtc_audio_processing1 libzbar0

  sudo zypper -n install --no-recommends -r packman-essentials gstreamer-plugins-bad gstreamer-plugins-ugly
  sudo zypper -n install --no-recommends -r packman-essentials gstreamer-plugins-libav
else
  sudo zypper -n install --no-recommends gstreamer-plugins-bad gstreamer-plugins-libav gstreamer-plugins-ugly
fi

## Flash Repo
sudo zypper -n install --no-recommends freshplayerplugin
#sudo zypper -n install --no-recommends http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
#
#sudo zypper -n install --no-recommends java-openjdk flash-plugin flash-player-ppapi
#
## upgrading:
## sudo dnf system-upgrade download
## sudo dnf system-upgrade reboot
#sudo zypper -n install --no-recommends dnf-plugin-system-upgrade
#
### GPU DRIVERS
#generate_nvidia_gpu_config() {
#  if [ -f /etc/default/grub ]; then
#    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
#
#    while true; do
#      read -p "Update GRUB [Yn]?   " updgr
#      case $updgr in
#        [Nn]* ) break;;
#        * )
#          while true; do
#            read -p "Using UEFI [Yn]?   " yn
#            case $yn in
#              [Nn]* )
#                sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
#                break 2;;
#              * )
#                sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
#                break 2;;
#            esac
#          done;;
#      esac
#    done
#  fi
#}
#
#install_mesa_vulkan_drivers() {
#
#  sudo zypper -n install --no-recommends mesa-dri-drivers.x86_64
#  sudo zypper -n install --no-recommends mesa-filesystem.x86_64
#  sudo zypper -n install --no-recommends mesa-libd3d.x86_64
#  sudo zypper -n install --no-recommends mesa-libEGL.x86_64
#  sudo zypper -n install --no-recommends mesa-libgbm.x86_64
#  sudo zypper -n install --no-recommends mesa-libGL.x86_64
#  sudo zypper -n install --no-recommends mesa-libglapi.x86_64
#  sudo zypper -n install --no-recommends mesa-libGLES.x86_64
#  sudo zypper -n install --no-recommends mesa-libGLU.x86_64
#  sudo zypper -n install --no-recommends mesa-libGLw.x86_64
#  sudo zypper -n install --no-recommends mesa-libOpenCL.x86_64
#  sudo zypper -n install --no-recommends mesa-libOSMesa.x86_64
#  sudo zypper -n install --no-recommends mesa-libxatracker.x86_64
#
#  sudo zypper -n install --no-recommends mesa-dri-drivers.i686
#  sudo zypper -n install --no-recommends mesa-filesystem.i686
#  sudo zypper -n install --no-recommends mesa-libd3d.i686
#  sudo zypper -n install --no-recommends mesa-libEGL.i686
#  sudo zypper -n install --no-recommends mesa-libgbm.i686
#  sudo zypper -n install --no-recommends mesa-libGL.i686
#  sudo zypper -n install --no-recommends mesa-libglapi.i686
#  sudo zypper -n install --no-recommends mesa-libGLES.i686
#  sudo zypper -n install --no-recommends mesa-libGLU.i686
#  sudo zypper -n install --no-recommends mesa-libGLw.i686
#  sudo zypper -n install --no-recommends mesa-libOpenCL.i686
#  sudo zypper -n install --no-recommends mesa-libOSMesa.i686
#  sudo zypper -n install --no-recommends mesa-libxatracker.i686
#
#  sudo zypper -n install --no-recommends vulkan-loader.x86_64
#  sudo zypper -n install --no-recommends mesa-vulkan-drivers.x86_64
#
#  sudo zypper -n install --no-recommends vulkan-loader.i686
#  sudo zypper -n install --no-recommends mesa-vulkan-drivers.i686
#  
#  sudo zypper -n install --no-recommends vulkan-tools.x86_64
#}
#
#while true; do
#  read -p "
#
#What GPU are you using?
#  [i]ntel
#  [a]md
#  [n]vidia
#  [v]m
#  [e]xit
#
#Enter GPU   " gpui
#  case $gpui in
#    [Ee]* )
#      break;;
#    [Vv]* )
#      break;;
#    [Ii]* )
#      sudo zypper -n install --no-recommends xorg-x11-drv-intel
#      install_mesa_vulkan_drivers
#
#      sudo cp -raf "$(pwd)/system-confs/20-intel.conf" "/etc/X11/xorg.conf.d/20-intel.conf"
#      echo Intel drivers installed;
#      break;;
#    [Aa]* )
#      while true; do
#        read -p "
#
#
#What driver to use?
#  Check: https://en.wikipedia.org/wiki/Template:AMD_graphics_API_support
#  [1] AMDGPU    - GCN 3, GCN 4 and newer
#  [2] ATI       - TeraScale 1, TeraScale 2, TeraScale 3, GCN 1, GCN 2
#  [e]xit
#  " amdd
#        case $amdd in
#          [1]* )
#            sudo zypper -n install --no-recommends xorg-x11-drv-amdgpu
#            install_mesa_vulkan_drivers
#
#            sudo cp -raf "$(pwd)/system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
#            sudo cp -raf "$(pwd)/system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
#            echo AMDGPU drivers installed;
#            break 2;;
#          [2]* )
#            sudo zypper -n install --no-recommends xorg-x11-drv-ati
#            install_mesa_vulkan_drivers
#
#            sudo cp -raf "$(pwd)/system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
#            echo ATI drivers installed;
#            break 2;;
#          [Ee]* ) break 2;;
#          * ) echo Invalid input
#        esac
#      done;;
#    [Nn]* )
#      sudo zypper -n install --no-recommends xorg-x11-drv-nvidia akmod-nvidia nvidia-xconfig
#
#      sudo zypper -n install --no-recommends vulkan-loader.x86_64 vulkan-tools.x86_64
#      sudo zypper -n install --no-recommends vulkan-loader.i686 vulkan-tools.i686
#
#      generate_nvidia_gpu_config
#      sudo nvidia-xconfig
#      echo NVIDIA drivers installed;
#      break;;
#  esac
#done
#
## Adding intel backlight
#if ls /sys/class/backlight | grep -q "^intel_backlight$"; then
#  if [ ! -d /etc/X11/xorg.conf.d ];then
#    sudo mkdir -p /etc/X11/xorg.conf.d
#  fi
#
#  if [ !$(ls /etc/X11/xorg.conf.d | grep -q ^20-intel.conf$) ];then
#    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
#  fi
#
#  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backligaht"; then
#    echo '
#Section "Device"
#  Identifier  "Card0"
#  Driver      "intel"
#  Option      "Backlight"  "intel_backlight"
#EndSection
#' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;
#    echo Added intel_backlight;
#  fi
#fi
#
### Hardware acceleration drivers installation
#sudo zypper -n install --no-recommends mesa-vdpau-drivers
#sudo zypper -n install --no-recommends libva-vdpau-driver
#
## Network
#sudo zypper -n install --no-recommends kernel-devel
#sudo dnf mark install kernel-devel
#while true; do
#  lspci -nnk | grep 0280 -A3
#  read -p "
#
#
#Wireless drivers installation:
#If your driver is not listed, check:
#https://wiki.archlinux.org/index.php/Wireless_network_configuration
#
#[1] Show Network Controller
#[2] Broadcom
#[m] Modprobe a module
#[e] Exit
#
#Enter action:   " wd
#  case $wd in
#    [Ee]* ) break;;
#    [Mm]* )
#      while true; do
#        read -p "Enter module:   " m
#        case $m in
#          * ) sudo modprobe -a $m; break;;
#        esac
#      done;;
#    [1] ) lspci | grep Network;;
#    [2] )
#      sudo zypper -n install --no-recommends NetworkManager-wifi broadcom-wl kmod-wl kernel-devel;
#      sudo akmods --force --kernel `uname -r` --akmod wl
#      sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
#      sudo modprobe wl
#      echo "
#Installation done...
#";;
#  esac
#done
#
## TRRS
#while true; do
#  read -p "
#Detect microphone plugged in a 4-pin 3.5mm (TRRS) jack [Yn]?   " yn
#  case $yn in
#    [Nn]* ) break;;
#    * )
#      while true; do
#        echo "
#Devices:
#"
#        aplay --list-devices
#        read -p "
#
#
#Check your HD Audio model here:
#https://dri.freedesktop.org/docs/drm/sound/hd-audio/models.html or
#http://git.alsa-project.org/?p=alsa-kernel.git;a=blob;f=Documentation/sound/alsa/HD-Audio-Models.txt;hb=HEAD
#
#Enter HD Audio Model (e.g. mbp101, macbook-pro, laptop-dmic etc) or [e]xit:   " hdam
#        case $hdam in
#          [Ee] ) break 2;;
#          * )
#            sudo touch /etc/modprobe.d/alsa-base.conf;
#            echo "
#options snd_hda_intel index=0
#options snd_hda_intel model=$hdam" | sudo tee /etc/modprobe.d/alsa-base.conf
#            break;;
#        esac
#      done;;
#  esac
#done
#
#
#if [ -d /etc/gdm ]; then
#  # use lightdm instead
#  sudo systemctl disable gdm
#fi
#
## Greeter
## sudo zypper -n install --no-recommends lightdm
#sudo zypper -n install --no-recommends google-noto-sans-fonts google-noto-fonts-common
#sudo zypper -n install --no-recommends lightdm-gtk
#sudo zypper -n install --no-recommends lightdm-gtk-greeter-settings
#sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
#
#sudo systemctl enable lightdm
#sudo systemctl set-default graphical.target
#
## Install window tiling manager
#sudo zypper -n install --no-recommends dmenu i3 i3status i3lock rxvt-unicode-256color-ml
#
## File manager
#sudo zypper -n install --no-recommends nautilus
#
#if [ ! -f "$HOME/.riced" ];then
#  mkdir -p $HOME/.config
#  mkdir -p $HOME/.config/i3
#
#  # Fix default i3 config
#  sudo cp /etc/i3/config $HOME/.config/i3/config
#  sudo chown $(whoami):$(whoami) $HOME/.config/i3/config
#
#  sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
#  sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config
#  sed -i 's/dmenu_run/dmenu/g' $HOME/.config/i3/config
#
#  sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
#  sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config
#  sudo sed -i 's/dmenu_run/dmenu/g' /etc/i3/config
#
#  cp -raf $(pwd)/rice/xinitrc $HOME/.xinitrc
#  cp -raf "$(pwd)/rice/config-i3-base" "$HOME/.Xresources"
#  sudo cp $HOME/.Xresources /root/.Xresources
#fi
#
#mainCWD=$(pwd)
#while true; do
#  read -p "
#
#Minimal installation done. Would you like to proceed [Yn]?   " yn
#  case $yn in
#    [Nn]* ) break;;
#    * )
#
#      # will use for manually installed packages, /tmp has limited space
#      cd /tmp
#
#      sudo zypper -n install --no-recommends curl wget vim-minimal vim-enhanced httpie lsof git tmux gedit
#
#      # theme icon
#      # git clone --recurse-submodules https://github.com/daniruiz/flat-remix.git
#      # cd flat-remix
#      # git fetch --tags
#      # tag=$(git describe --tags `git rev-list --tags --max-count=1`)
#      # if [ ${#tag} -ge 1 ]; then
#      #   git checkout $tag
#      # fi
#      # git tag -f "git-$(git rev-parse --short HEAD)"
#      # sudo mkdir -p /usr/share/icons && sudo cp -raf Flat-Remix* /usr/share/icons/
#      # sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix
#      # cd /tmp
#      sudo zypper -n install --no-recommends papirus-icon-theme
#
#      # display
#      sudo zypper -n install --no-recommends feh arandr lxappearance xbacklight xorg-x11-server-utils
#
#      # package manager
#      # sudo zypper -n install --no-recommends dnfdragora dnfdragora-updater
#      sudo zypper -n install --no-recommends notification-daemon
#
#      # Generic notification
#      # echo "
#      # [D-BUS Service]
#      # Name=org.freedesktop.Notifications
#      # Exec=/usr/libexec/notification-daemon
#      # " | sudo tee /usr/share/dbus-1/services/org.freedesktop.Notifications.service
#
#      # # Xfce notification
#      # echo "
#      # [D-BUS Service]
#      # Name=org.freedesktop.Notifications
#      # Exec=/usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd
#      # SystemdService=xfce4-notifyd.service
#      # " | sudo tee /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
#
#      # Make sure other notification service exists to give way to dunst
#      if [ -f /usr/share/dbus-1/services/org.freedesktop.Notifications.service ]; then
#        sudo rm /usr/share/dbus-1/services/org.freedesktop.Notifications.service
#      fi
#
#      if [ -f /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service ]; then
#        sudo rm /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
#      fi
#
#      # audio
#      sudo zypper -n install --no-recommends alsa-utils
#      sudo zypper -n install --no-recommends pulseaudio pulseaudio-utils pavucontrol
#
#      amixer sset "Master" unmute
#      amixer sset "Speaker" unmute
#      amixer sset "Headphone" unmute
#      amixer sset "Mic" unmute
#      amixer sset "Mic Boost" unmute
#
#      amixer sset "Master" 100%
#      amixer sset "Speaker" 100%
#      amixer sset "Headphone" 100%
#      amixer sset "Mic" 100%
#      amixer sset "Mic Boost" 100%
#
#      # MANUAL 3b4f8b3: PulseAudio Applet. Some are already installed
#      sudo zypper -n install --no-recommends glib2-devel gtk3-devel libnotify-devel
#      sudo zypper -n install --no-recommends pulseaudio-libs-devel libX11-devel
#      sudo zypper -n install --no-recommends autoconf automake pkgconf
#
#      sudo dnf mark install gtk3 libnotify pulseaudio-libs
#
#      git clone --recurse-submodules https://github.com/fernandotcl/pa-applet.git
#      cd pa-applet
#
#      git fetch --tags
#      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
#
#      if [ ${#tag} -ge 1 ]; then
#        git checkout $tag
#      fi
#
#      git tag -f "git-$(git rev-parse --short HEAD)"
#      ./autogen.sh && ./configure && make && sudo make install
#      cd /tmp
#
#      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
#      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf
#
#      # network manager
#      sudo zypper -n install --no-recommends NetworkManager network-manager-applet
#      sudo systemctl enable NetworkManager
#
#      # fonts - fc-list
#      # git clone https://github.com/ryanoasis/nerd-fonts.git
#      # ./install
#      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
#      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
#      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
#      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
#
#      sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
#      sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
#      sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
#      sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
#      sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"
#
#      # terminal
#      sudo zypper -n install --no-recommends neofetch
#
#      # gtk theme change
#      sudo zypper -n install --no-recommends gtk2-engines gtk-murrine-engine gtk2 gtk3
#
#      # mouse cursor theme
#      sudo zypper -n install --no-recommends breeze-cursor-theme
#      sudo ln -s /usr/share/icons/breeze_cursors /usr/share/icons/Breeze
#
#      # notification, system monitor, compositor, image on terminal
#      sudo zypper -n install --no-recommends dunst conky compton w3m
#      sudo zypper -n install --no-recommends ffmpegthumbnailer
#
#      # for vifm
#      sudo zypper -n install --no-recommends python3-pip
#      sudo zypper -n install --no-recommends redhat-rpm-config
#
#      # https://pillow.readthedocs.io/en/stable/installation.html
#      sudo zypper -n install --no-recommends python3-devel libjpeg-turbo-devel zlib-devel libXext-devel
#      sudo pip3 install ueberzug
#      sudo zypper -n install --no-recommends poppler-utils
#      sudo zypper -n install --no-recommends mediainfo
#      sudo zypper -n install --no-recommends transmission-cli transmission-common
#      sudo zypper -n install --no-recommends zip unzip tar xz-libs unrar
#      sudo zypper -n install --no-recommends catdoc odt2txt
#
#      # MANUAL 2.12.c: i3lock-color. Some are already installed
#      sudo dnf remove -y i3lock
#      sudo zypper -n install --no-recommends cairo-devel libev-devel libjpeg-devel libxkbcommon-x11-devel
#      sudo zypper -n install --no-recommends pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel autoconf automake
#
#      sudo zypper -n install --no-recommends cairo libev libjpeg-turbo libxcb libxkbcommon
#      sudo zypper -n install --no-recommends libxkbcommon-x11 xcb-util-image pkgconf
#
#      sudo dnf mark install cairo libev libjpeg-turbo libxcb libxkbcommon libxkbcommon-x11 xcb-util-image
#
#      git clone --recurse-submodules https://github.com/PandorasFox/i3lock-color.git
#      cd i3lock-color
#
#      git fetch --tags
#      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
#
#      if [ ${#tag} -ge 1 ]; then
#        git checkout $tag
#      fi
#
#      git tag -f "git-$(git rev-parse --short HEAD)"
#      autoreconf -fi && ./configure && make && sudo make install
#      echo "auth include system-auth" | sudo tee /etc/pam.d/i3lock
#      cd /tmp
#
#      # terminal-based file viewer
#      sudo zypper -n install --no-recommends ranger
#      sudo zypper -n install --no-recommends vifm
#
#      # requirements for ranger [scope.sh]
#      sudo zypper -n install --no-recommends file libcaca python3-pygments atool libarchive unrar lynx
#      sudo zypper -n install --no-recommends mupdf transmission-cli mediainfo odt2txt python3-chardet
#
#      # i3wm customization, dmenu replacement, i3status replacement
#      sudo zypper -n install --no-recommends rofi
#
#      # MANUAL 4.16.1: i3-gaps
#      sudo dnf remove -y i3
#      sudo zypper -n install --no-recommends libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel
#      sudo zypper -n install --no-recommends xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel
#      sudo zypper -n install --no-recommends libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel
#      sudo zypper -n install --no-recommends pcre-devel pango-devel automake git gcc
#
#      sudo zypper -n install --no-recommends libev libxkbcommon-x11 perl pango startup-notification
#      sudo zypper -n install --no-recommends xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl
#
#      sudo dnf mark install libev libxkbcommon-x11 perl pango startup-notification xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl
#
#      git clone --recurse-submodules https://github.com/Airblader/i3.git i3-gaps
#      cd i3-gaps
#
#      git fetch --tags
#      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
#
#      if [ ${#tag} -ge 1 ]; then
#        git checkout $tag
#      fi
#
#      git tag -f "git-$(git rev-parse --short HEAD)"
#      autoreconf -fi && rm -rf build/ && mkdir -p build && cd build/
#      ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
#      make && sudo make install
#
#      cd /tmp
#
#      # MANUAL 3.3.1: polybar
#      sudo zypper -n install --no-recommends cairo-devel xcb-proto xcb-util-devel xcb-util-cursor-devel xcb-util-image-devel xcb-util-wm-devel xcb-util-xrm-devel
#      sudo zypper -n install --no-recommends alsa-lib-devel libcurl-devel jsoncpp-devel libmpdclient-devel pulseaudio-libs-devel libnl3-devel cmake wireless-tools-devel
#      sudo zypper -n install --no-recommends gcc-c++ gcc python python2 git pkgconf
#
#      sudo zypper -n install --no-recommends cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm
#      sudo zypper -n install --no-recommends alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools
#
#      # ncmpcpp playlist
#      # 1) go to browse
#      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
#      # 3) press "A"
#      #
#      # r: repeat, z: shuffle, y: repeat one
#      sudo zypper -n install --no-recommends mpd mpc ncmpcpp
#      sudo systemctl disable mpd
#      sudo systemctl stop mpd
#
#      sudo dnf mark install cairo xcb-util-cursor xcb-util-image xcb-util-wm xcb-util-xrm
#      sudo dnf mark install alsa-lib curl jsoncpp libmpdclient pulseaudio-libs libnl3 wireless-tools
#      sudo dnf mark install mpd mpc ncmpcpp
#
#      git clone --recurse-submodules https://github.com/jaagr/polybar.git
#      cd polybar
#
#      git fetch --tags
#      tag=$(git describe --tags `git rev-list --tags --max-count=1`)
#
#      if [ ${#tag} -ge 1 ]; then
#        git checkout $tag
#      fi
#
#      git tag -f "git-$(git rev-parse --short HEAD)"
#      rm -rf build/ && mkdir -p build && cd build/
#      cmake .. && make -j$(nproc) && sudo make install
#
#      cd /tmp
#
#      # popup calendar
#      # sudo zypper -n install --no-recommends xdotool yad
#
#      sudo zypper -n install --no-recommends scrot
#
#      sudo zypper -n install --no-recommends accountsservice
#
#      sudo dnf remove -y alsa-lib-devel cairo-devel glib2-devel gtk3-devel jsoncpp-devel \
#        libcurl-devel libev-devel libjpeg-devel libjpeg-turbo-devel libmpdclient-devel \
#        libnl3-devel libnotify-devel libX11-devel libxcb-devel libXext-devel libXinerama-devel \
#        libxkbcommon-devel libxkbcommon-x11-devel libXrandr-devel pam-devel pango-devel pcre-devel \
#        pulseaudio-libs-devel python3-devel startup-notification-devel wireless-tools-devel xcb-proto \
#        xcb-util-cursor-devel xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-wm-devel \
#        xcb-util-xrm-devel yajl-devel zlib-devel
#      sudo dnf -y autoremove
#      cd $mainCWD
#
#      user=$(whoami)
#
#      echo "
#[User]
#Icon=/var/lib/AccountsService/icons/$user.png
#XSession=i3
#SystemAccount=false
#" | sudo tee /var/lib/AccountsService/users/$user
#
#      sudo cp $(pwd)/rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
#      sudo cp $(pwd)/rice/images/avatar/default-user.png /usr/share/pixmaps/default-user.png
#      sudo chown root:root /var/lib/AccountsService/users/$user
#      sudo chown root:root /var/lib/AccountsService/icons/$user.png
#
#      sudo chmod 644 /var/lib/AccountsService/users/$user
#      sudo chmod 644 /var/lib/AccountsService/icons/$user.png
#
#      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
#      bash $(pwd)/scripts/update-libinput.sh
#
#      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/dnf" | sudo tee -a "/etc/sudoers"
#
#      if [ ! -f $HOME/.riced ];then
#        bash $(pwd)/scripts/setup-user-configs.sh
#        bash $(pwd)/scripts/update-scripts.sh
#        touch $HOME/.riced
#      fi
#
#      cd $mainCWD
#
#      # sed -i "s/# exec --no-startup-id dnfdragora-updater/exec --no-startup-id dnfdragora-updater/g" $HOME/.config/i3/config
#      # sed -i "s/# for_window \[class=\"Dnfdragora-updater\"\]/for_window [class=\"Dnfdragora-updater\"]/g" $HOME/.config/i3/config
#
#      mkdir -p "$HOME/.config/neofetch"
#      cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/$os.conf
#
#      sudo mkdir -p /usr/share/icons/default
#      echo "
#[Icon Theme]
#Inherits=Breeze
#      " | sudo tee /usr/share/icons/default/index.theme
#
#      sudo mkdir -p /root/.vim
#      sudo cp -raf $HOME/.vim/* /root/.vim
#      sudo cp -raf $HOME/.vimrc /root/.vimrc
#
#      sudo cp -rf $(pwd)/rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
#
#      bash $(pwd)/scripts/update-scripts.sh
#      bash $(pwd)/scripts/update-screen-detector.sh
#      bash $(pwd)/scripts/update-themes.sh
#
#      echo '
#
#####################################
#####################################
####                              ###
####    RICING COMPLETE...        ###
####                              ###
#####################################
#####################################
#
#'
#
#      break;;
#  esac
#done
#
#
#