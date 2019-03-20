
#!/bin/bash

while true; do
  read -p "Will use for dual boot with other linux [yN]?   " wdb
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

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2:

usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Would you like to proceed [Yn]?   " wultp
                    case $wultp in
                      [Nn]* ) ;;
                      * )
                        break 4;;
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

if [ ! -f /etc/X11/xorg.conf ];then
  sudo touch /etc/X11/xorg.conf;
fi

# Font DIRS for X.org
echo '
Section "Files"
  FontPath    "/usr/share/fonts/100dpi"
  FontPath    "/usr/share/fonts/75dpi"
  FontPath    "/usr/share/fonts/cantarell"
  FontPath    "/usr/share/fonts/cyrillic"
  FontPath    "/usr/share/fonts/encodings"
  FontPath    "/usr/share/fonts/misc"
  FontPath    "/usr/share/fonts/truetype"
  FontPath    "/usr/share/fonts/TTF"
  FontPath    "/usr/share/fonts/util"
  FontPath    "/usr/share/fonts/nerd-fonts-complete/ttf"
  FontPath    "/usr/share/fonts/nerd-fonts-complete/otf"
EndSection
' | sudo tee /etc/X11/xorg.conf

# install AUR helper: yay
git clone https://aur.archlinux.org/yay.git
cd yay
yes | makepkg --syncdeps --install
yes | yay -Syu
cd ..
rm -rf yay

# https://www.archlinux.org/groups/x86_64/base-devel/
# Current libs (3/15/2019)
# autoconf    automake     binutils    bison      fakeroot
# file        findutils    flex        gawk       gcc
# gettext     grep         groff       gzip       libtool
# m4          make         pacman      patch      pkgconf
# sed         sudo         systemd     texinfo    util-linux
# which
while true; do
  read -p "This package might installed during installation. Install base-devel [yN]?   " p
  case $p in
    [Yy]* )
      yes | sudo pacman -S base-devel --noconfirm
      break;;
    * ) break;;
  esac
done

# Sound
yes | sudo pacman -S alsa-utils

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

# Gstreamer
yes | sudo pacman -S gstreamer
yes | sudo pacman -S gst-libav
yes | sudo pacman -S gst-plugins-bad
yes | sudo pacman -S gst-plugins-base
yes | sudo pacman -S gst-plugins-base-libs
yes | sudo pacman -S gst-plugins-good
yes | sudo pacman -S gst-plugins-ugly

# Browser packages
yes | sudo pacman -S jre-openjdk flashplugin pepper-flash

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* )
      yes | sudo pacman -S intel-ucode;
      break;;
    [Aa]* )
      yes | sudo pacman -S amd-ucode;
      break;;
    * ) echo Invalid input
  esac
done

generate_intel_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/20-intel.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  echo '
Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
EndSection

Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
  Option      "TearFree" "true"
  Option      "DRI"    "3"
EndSection
' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf;

}


generate_ati_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/20-radeon.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-radeon.conf;
  fi

  echo '
Section "Device"
  Identifier "Radeon"
  Driver "radeon"
EndSection

Section "Device"
  Identifier  "Radeon"
  Driver "radeon"
  Option "AccelMethod" "glamor"
  Option "DRI" "3"
  Option "TearFree" "on"
  Option "ColorTiling" "on"
  Option "ColorTiling2D" "on"
  Option "SWCursor" "True"
EndSection
' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf;

}

generate_amd_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/10-screen.conf ];then
    sudo touch /etc/X11/xorg.conf.d/10-screen.conf;
  fi

  if [ ! -f /etc/X11/xorg.conf.d/20-radeon.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-radeon.conf;
  fi

  echo '
Section "Screen"
  Identifier     "Screen"
  DefaultDepth    24
  SubSection      "Display"
    Depth         24
  EndSubSection
EndSection
' | sudo tee /etc/X11/xorg.conf.d/10-screen.conf;

  echo '
Section "Device"
  Identifier "AMD"
  Driver "amdgpu"
EndSection

Section "Device"
  Identifier  "AMD"
  Driver "amdgpu"
  Option "DRI" "3"
  Option "TearFree" "on"
  Option "SWCursor" "True"
EndSection
' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf;

}

generate_nvidia_gpu_config() {
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /g' /etc/default/grub;
  sudo mkdir -p /etc/pacman.d/hooks

  if [ ! -f /etc/pacman.d/hooks/nvidia.hook ];then
    sudo touch /etc/pacman.d/hooks/nvidia.hook;
  fi

  echo "
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
Target=linux-lts

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
" | sudo tee /etc/pacman.d/hooks/nvidia.hook;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P
  fi
}

enable_amdgpu_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(amdgpu radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(amdgpu radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P;
  fi
}

enable_amdati_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P;
  fi
}

install_mesa_vulkan_drivers() {
  yes | sudo pacman -S mesa lib32-mesa;
  yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
}

while true; do
  echo "Your GPU: ";
  lspci -k | grep -A 2 -E "(VGA|3D)";
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
      yes | sudo pacman -S xf86-video-intel;
      install_mesa_vulkan_drivers
      yes | sudo pacman -S vulkan-intel lib32-vulkan-intel;

      generate_intel_gpu_config
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

Enter driver to use: " amdd
        case $amdd in
          [1]* )
            yes | sudo pacman -S xf86-video-amdgpu;
            install_mesa_vulkan_drivers;
            yes | sudo pacman -S vulkan-radeon lib32-vulkan-radeon;

            generate_amd_gpu_config
            enable_amdgpu_kms
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            yes | sudo pacman -S xf86-video-ati;
            install_mesa_vulkan_drivers;
            yes | sudo pacman -S vulkan-radeon lib32-vulkan-radeon;

            generate_ati_gpu_config
            enable_amdati_kms
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      while true; do
        read -p "Using LTS kernel [yN]?   " ults
        case $ults in
          [Yy]* )
            yes | sudo pacman -S nvidia-lts;

            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
            yes | sudo pacman -S nvidia-utils lib32-nvidia-utils;

            generate_nvidia_gpu_config
            sudo nvidia-xconfig
            echo NVIDIA drivers installed;
            break 2;;
          * )
            yes | sudo pacman -S nvidia;

            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
            yes | sudo pacman -S nvidia-utils lib32-nvidia-utils;

            generate_nvidia_gpu_config
            sudo nvidia-xconfig
            echo NVIDIA drivers installed;
            break 2;;
        esac
      done
  esac
done

# Adding intel backlight
if ls /sys/class/backlight | grep -q "^intel_backlight$"; then
  if [ !$(ls /etc/X11/xorg.conf.d | grep -q ^20-intel.conf$) ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  echo '
Section "Device"
  Identifier  "Card0"
  Driver      "intel"
  Option      "Backlight"  "intel_backlight"
EndSection
  ' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf;
    echo Added intel_backlight;
fi

## Hardware acceleration drivers installation
yes | sudo pacman -S mesa-vdpau lib32-mesa-vdpau;
yes | sudo pacman -S libva-mesa-driver lib32-libva-mesa-driver;

## Fallback hardware video acceleration
yes | sudo pacman -S libva-vdpau-driver libvdpau-va-gl;

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

Enter action: " wd
  case $wd in
    [Ee]* ) break;;
    [Mm]* )
      while true; do
        read -p "Enter module:   " m
        case $m in
          * ) sudo modprobe $m; break;;
        esac
      done;;
    [1] ) lspci | grep Network;;
    [2] ) sudo pacman -S broadcom-wl-dkms; echo "
Installation done...
";;
  esac
done

while true; do
  echo "


For details, read:
https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#Correctly_detect_microphone_plugged_in_a_4-pin_3.5mm_(TRRS)_jack

"
  read -p "Detect microphone plugged in a 4-pin 3.5mm (TRRS) jack [Yn]?   " yn
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

# Install display manager
yes | sudo pacman -S lightdm
yes | sudo pacman -S noto-fonts
yes | sudo pacman -S lightdm-gtk-greeter
yes | sudo pacman -S lightdm-gtk-greeter-settings
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm

# Install window tiling manager
yes | sudo pacman -S dmenu i3-wm i3status i3lock rxvt-unicode

# File manager
yes | sudo pacman -S nautilus
# yes | sudo pacman -S pcmanfm-gtk3

if [ ! -f "$HOME/.riced" ];then
  mkdir -p $HOME/.config
  mkdir -p $HOME/.config/i3

  # Fix default i3 config
  sudo cp /etc/i3/config $HOME/.config/i3/config
  sudo chown $(whoami):wheel $HOME/.config/i3/config

  sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
  sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config
  sed -i 's/dmenu_run/dmenu/g' $HOME/.config/i3/config

  sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
  sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config
  sudo sed -i 's/dmenu_run/dmenu/g' /etc/i3/config

  # Fix default xinitrc config
  # cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
  # sudo chown $(whoami):wheel $HOME/.xinitrc

  # sed -i 's/twm&/ /g' $HOME/.xinitrc
  # sed -i 's/xclock -geometry 50x50-1+1 &/ /g' $HOME/.xinitrc
  # sed -i 's/xterm -geometry 80x50+494+51 &/ /g' $HOME/.xinitrc
  # sed -i 's/xterm -geometry 80x20+494-0 &/ /g' $HOME/.xinitrc
  # sed -i 's/exec xterm -geometry 80x66+0+0/exec i3/g' $HOME/.xinitrc

  # sudo sed -i 's/twm&/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xclock -geometry 50x50-1+1 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xterm -geometry 80x50+494+51 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xterm -geometry 80x20+494-0 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/exec xterm -geometry 80x66+0+0/ /g' /etc/X11/xinit/xinitrc

  cp -raf $(pwd)/rice/xinitrc $HOME/.xinitrc

  echo '
*.foreground:   #c5c8c6
*.background:   #1d1f21
*.cursorColor:  #c5c8c6
*.color0:       #282a2e
*.color8:       #373b41
*.color1:       #a54242
*.color9:       #cc6666
*.color2:       #8c9440
*.color10:      #b5bd68
*.color3:       #de935f
*.color11:      #f0c674
*.color4:       #5f819d
*.color12:      #81a2be
*.color5:       #85678f
*.color13:      #b294bb
*.color6:       #5e8d87
*.color14:      #8abeb7
*.color7:       #707880
*.color15:      #c5c8c6

  ' | tee $HOME/.Xresources

  sudo cp $HOME/.Xresources /root/.Xresources
fi

mainCWD=$(pwd)
while true; do
  read -p "

Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * ) 

      # update all
      sudo pacman -Syu

      # theme icon
      yes | yay -S flat-remix-git
      yes | yay -S flat-remix-gtk-git
      sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix

      # display
      yes | sudo pacman -S nitrogen arandr lxappearance xorg-xbacklight xorg-xrandr

      # package manager - arch
      # yes | yay -S pamac-tray-appindicator pamac-aur --noconfirm

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
      yes | sudo pacman -S alsa-utils 
      yes | sudo pacman -S pulseaudio pavucontrol --noconfirm
      yes | yay -S pa-applet-git

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      # network manager
      yes | sudo pacman -S networkmanager network-manager-applet
      sudo systemctl enable NetworkManager

      # fonts
      yes | sudo pacman -S noto-fonts
      # yes | yay -S nerd-fonts-complete
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
      yes | sudo pacman -S neofetch

      # gtk theme change
      yes | sudo pacman -S gtk-engines gtk-engine-murrine gtk2 gtk3

      # mouse cursor theme, notification, system monitor, compositor, image on terminal
      yes | yay -S xcursor-breeze
      yes | sudo pacman -S dunst conky compton w3m
      yes | sudo pacman -S ffmpegthumbnailer

      # for vifm
      # yes | sudo pacman -S python-pip
      # sudo pip3 install ueberzug

      # better desktop locker
      yes | yay -S i3lock-color-git

      # terminal-based file viewer
      yes | sudo pacman -S ranger
      # yes | sudo pacman -S vifm

      # requirements for ranger [scope.sh]
      yes | sudo pacman -S file libcaca pygmentize atool libarchive unrar lynx
      yes | sudo pacman -S mupdf-tools transmission-cli mediainfo odt2txt python-chardet

      # for ranger
      yes | yay -S rxvt-unicode-pixbuf

      # for polybar
      #
      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      yes | sudo pacman -S mpd mpc ncmpcpp
      yes | sudo pacman -S libpulse jsoncpp libmpdclient
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      # i3wm customization, dmenu replacement, i3status replacement
      yes | sudo pacman -S i3-gaps rofi
      yes | yay -S polybar --noconfirm

      # popup calendar
      # sudo pacman -S xdotool
      # yay -S yad

      yes | sudo pacman -S scrot

      yes | sudo pacman -S accountsservice
      user=$(whoami)

      echo "
[User]
Icon=/var/lib/AccountsService/icons/$user.png
XSession=i3
SystemAccount=false
" | sudo tee /var/lib/AccountsService/users/$user

      sudo cp $(pwd)/rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
      sudo cp $(pwd)/rice/images/avatar/default-user.png /usr/share/pixmaps/default-user.png
      sudo chown root:root /var/lib/AccountsService/users/$user
      sudo chown root:root /var/lib/AccountsService/icons/$user.png

      sudo chmod 644 /var/lib/AccountsService/users/$user
      sudo chmod 644 /var/lib/AccountsService/icons/$user.png

      if [ ! -f /usr/share/X11/xorg.conf.d/40-libinput.conf ];then
        sudo touch /usr/share/X11/xorg.conf.d/40-libinput.conf;
      fi

      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
      echo '
# Match on all types of devices but joysticks
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "NaturalScrolling" "true"
EndSection

Section "InputClass"
  Identifier "libinput keyboard catchall"
  MatchIsKeyboard "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "Tapping" "true"
  Option "ScrollMethod" "twofinger"
  Option "NaturalScrolling" "true"
  Option "ClickMethod" "clickfinger"
  Option "TappingDrag" "true"
EndSection

Section "InputClass"
  Identifier "libinput touchscreen catchall"
  MatchIsTouchscreen "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput tablet catchall"
  MatchIsTablet "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection
      ' | sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf

      if [ ! -f $HOME/.riced ]; then
        mkdir -p $HOME/.icons/default
        echo "
[Icon Theme]
Inherits=Breeze
        " | tee $HOME/.icons/default/index.theme

        while true; do
          read -p "Do you want to configure git [Yn]?   " yn
          case $yn in
            [Nn]* ) break;;
            * )
              while true; do
                read -p "Enter email or [e]xit:   " email
                case $email in
                  [Ee] ) break;;
                  * )
                    while true; do
                      read -p "Enter name or [e]xit:   " name
                      case $name in
                        [Ee] ) break 2;;
                        * )
                          while true; do
                            read -p "Enter username or [e]xit:   " username
                            case $username in
                              [Ee] ) break 3;;
                              * ) echo "
[user]
  email = $email
  name = $name
  username = $username
[diff]
  tool = vimdiff
[difftool]
  prompt = false
[color]
  ui = auto
[color \"branch\"]
  current = yellow reverse
  local = yellow
  remote = green
[color \"diff\"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold
[color \"status\"]
  added = yellow
  changed = green
  untracked = cyan
" | tee $HOME/.gitconfig;

                                break 4;;
                            esac
                          done;;
                      esac
                    done;;
                esac
              done;;
          esac
        done

        # create folders for executables
        mkdir -p $HOME/.config/audio
        mkdir -p $HOME/.config/display
        mkdir -p $HOME/.config/conky
        mkdir -p $HOME/.config/keyboard
        mkdir -p $HOME/.config/i3
        mkdir -p $HOME/.config/kali
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/network
        mkdir -p $HOME/.config/touchpad
        mkdir -p $HOME/.config/polybar
        mkdir -p $HOME/.config/themes
        # mkdir -p $HOME/.config/vifm
        # mkdir -p $HOME/.config/vifm/scripts

        # create folders for configs
        mkdir -p  "$HOME/.config/Code"
        mkdir -p  "$HOME/.config/Code/User"
        mkdir -p  "$HOME/.config/Code - OSS"
        mkdir -p  "$HOME/.config/Code - OSS/User"
        mkdir -p  "$HOME/.config/gtk-3.0"

        # copy vscode user settings
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code/User/keybindings.json"
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

        # copy executables
        cp $(pwd)/scripts/volume-manager.sh                   $HOME/.config/audio/volume-manager.sh
        cp $(pwd)/scripts/brightness-manager.sh               $HOME/.config/display/brightness-manager.sh
        cp $(pwd)/scripts/lockscreen.sh                       $HOME/.config/display/lockscreen.sh
        cp $(pwd)/scripts/generate-conky-config.sh            $HOME/.config/conky/generate-conky-config.sh
        cp $(pwd)/scripts/generate-conky-helper.sh            $HOME/.config/conky/generate-conky-helper.sh
        cp $(pwd)/scripts/keyboard-disabler.sh                $HOME/.config/keyboard/keyboard-disabler.sh
        cp $(pwd)/scripts/polybar.sh                          $HOME/.config/i3/polybar.sh
        cp $(pwd)/scripts/polkit-launch.sh                    $HOME/.config/i3/polkit-launch.sh
        cp $(pwd)/scripts/startup.sh                          $HOME/.config/i3/startup.sh
        cp $(pwd)/scripts/kali-rofi.sh                        $HOME/.config/kali/rofi.sh
        cp $(pwd)/scripts/kali-launch.sh                      $HOME/.config/kali/launch.sh
        cp $(pwd)/scripts/spawn-mpd.sh                        $HOME/.config/mpd/spawn-mpd.sh
        cp $(pwd)/scripts/network-connect.sh                  $HOME/.config/network/network-connect.sh
        cp $(pwd)/scripts/update-mirrors.sh                   $HOME/.config/network/update-mirrors.sh
        cp $(pwd)/scripts/toggle-touchpad.sh                  $HOME/.config/touchpad/toggle-touchpad.sh
        cp $(pwd)/scripts/popup-calendar.sh                   $HOME/.config/polybar/popup-calendar.sh
        cp $(pwd)/scripts/update-checker.sh                   $HOME/.config/polybar/update-checker.sh
        cp $(pwd)/scripts/change-theme.sh                     $HOME/.config/themes/change-theme.sh
        cp $(pwd)/scripts/update-polybar-network-interface.sh $HOME/.config/themes/update-polybar-network-interface.sh
        # cp $(pwd)/scripts/vifm-run.sh                         $HOME/.config/vifm/scripts/vifm-run.sh
        # cp $(pwd)/scripts/vifm-viewer.sh                      $HOME/.config/vifm/scripts/vifm-viewer.sh

        # copy keyboard-disabler icons
        # cp $(pwd)/rice/images/keyboard/* $HOME/.config/keyboard

        # make executables
        sudo chmod +x $HOME/.config/audio/volume-manager.sh
        sudo chmod +x $HOME/.config/display/brightness-manager.sh
        sudo chmod +x $HOME/.config/display/lockscreen.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-config.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-helper.sh
        sudo chmod +x $HOME/.config/keyboard/keyboard-disabler.sh
        sudo chmod +x $HOME/.config/i3/polybar.sh
        sudo chmod +x $HOME/.config/i3/polkit-launch.sh
        sudo chmod +x $HOME/.config/i3/startup.sh
        sudo chmod +x $HOME/.config/kali/rofi.sh
        sudo chmod +x $HOME/.config/kali/launch.sh
        sudo chmod +x $HOME/.config/mpd/spawn-mpd.sh
        sudo chmod +x $HOME/.config/network/network-connect.sh
        sudo chmod +x $HOME/.config/network/update-mirrors.sh
        sudo chmod +x $HOME/.config/touchpad/toggle-touchpad.sh
        sudo chmod +x $HOME/.config/polybar/popup-calendar.sh
        sudo chmod +x $HOME/.config/polybar/update-checker.sh
        sudo chmod +x $HOME/.config/themes/change-theme.sh
        sudo chmod +x $HOME/.config/themes/update-polybar-network-interface.sh
        # sudo chmod +x $HOME/.config/vifm/scripts/vifm-run.sh
        # sudo chmod +x $HOME/.config/vifm/scripts/vifm-viewer.sh

        cp -rf $(pwd)/rice/bashrc      $HOME/.bashrc

        # vifm
        # cp -raf $(pwd)/rice/vifmrc  $HOME/.config/vifm/vifmrc

        # copy vim colors
        mkdir -p $HOME/.vim
        cp -raf $(pwd)/rice/vim/*  $HOME/.vim
        cp -raf $(pwd)/rice/vimrc  $HOME/.vimrc

        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

        # copy wallpapers
        mkdir -p $HOME/Pictures/wallpapers
        cp -rf $(pwd)/rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

        # copy ranger configs
        mkdir -p $HOME/.config/ranger
        cp -rf $(pwd)/rice/ranger/* $HOME/.config/ranger

        # copy i3 config
        mkdir -p $HOME/.config/i3
        cp -rf $(pwd)/rice/config-i3      $HOME/.config/i3/config
        cp -rf $(pwd)/rice/i3status.conf  $HOME/.config/i3/i3status.conf

        sed -i 's/# exec --no-startup-id pa-applet/exec --no-startup-id pa-applet/g' $HOME/.config/i3/config

        # copy ncmpcpp config
        mkdir -p $HOME/.ncmpcpp
        cp -rf $(pwd)/rice/config-ncmpcpp $HOME/.ncmpcpp/config

        # copy polybar config
        mkdir -p $HOME/.config/polybar
        cp -rf $(pwd)/rice/config-polybar $HOME/.config/polybar/config
        bash $(pwd)/scripts/update-polybar-network-interface.sh

        # copy i3status config
        sudo cp -rf $(pwd)/rice/i3status.conf /etc/i3status.conf

        # copy mpd config
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/mpd/playlists
        cp -rf $(pwd)/rice/mpd.conf $HOME/.config/mpd/mpd.conf

        # copy neofetch config
        mkdir -p $HOME/.config/neofetch
        cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/config.conf

        # copy compton config
        mkdir -p $HOME/.config/compton
        cp -rf $(pwd)/rice/compton.conf $HOME/.config/compton/config.conf

        # copy dunst config
        mkdir -p $HOME/.config/dunst
        cp -rf $(pwd)/rice/dunstrc $HOME/.config/dunst/dunstrc

        while true; do
          read -p "Do you want to activate keyboard disabler [yN]?   " yn
          case $yn in
            [Yy]* )
              while true; do
                xinput
                read -p "

Enter device ID:   " did
                case $did in
                  * )
                    echo "exec --no-startup-id ~/.config/keyboard/keyboard-disabler.sh $did" | tee -a $HOME/.config/i3/config
                    break 2;;
                esac
              done;;
            * ) break;;
          esac
        done

        touch $HOME/.riced
      fi

      # NOTE: needs adjustment for the sake of fedora
      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

      cd $mainCWD

      # sed -i "s/# exec --no-startup-id pamac-tray/exec --no-startup-id pamac-tray/g" $HOME/.config/i3/config
      # sed -i "s/# for_window \[class=\"Pamac-manager\"\]/for_window [class=\"Pamac-manager\"]/g" $HOME/.config/i3/config

      os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))
      mkdir -p "$HOME/.config/neofetch"
      cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      echo "
[Icon Theme]
Inherits=Breeze
      " | sudo tee /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo mkdir -p /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

      bash $(pwd)/scripts/update-screen-detector.sh
      bash $(pwd)/scripts/update-themes.sh
      yes | sudo pacman -Rns $(pacman -Qtdq)

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
