
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"

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

if [ ! -f /etc/X11/xorg.conf ];then
  sudo touch /etc/X11/xorg.conf;
fi

yes | sudo pacman -Syyu

# Font DIRS for X.org
sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$os" != "manjaro" ]; then
  while true; do
    read -p "Install LTS kernel? [y]es | [n]o   " ilts
    case $ilts in
      [Yy]* )
        yes | sudo pacman -S linux-lts linux-lts-headers
        break;;
      [Nn]* )
        yes | sudo pacman -S linux linux-headers
        break;;
      * ) echo Invalid input
    esac
  done;
else
  major=$(uname -r | cut -f 1 -d .);
  minor=$(uname -r | cut -f 2 -d .);
  version=$(echo $major$minor);
  yes | sudo pacman -S linux$version linux$version-headers;
fi

# install AUR helper: yay
git clone https://aur.archlinux.org/yay.git
cd yay
yes | makepkg --syncdeps --install
yes | yay -Syyu
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

yes | sudo pacman -S polkit-gnome

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

generate_nvidia_gpu_config() {
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
Target=linux$1

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
" | sudo tee /etc/pacman.d/hooks/nvidia.hook;

  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /g' /etc/default/grub;

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  else
    sudo mkinitcpio -P
  fi
}

enable_amdgpu_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(amdgpu radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(amdgpu radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  else
    sudo mkinitcpio -P
  fi
}

enable_amdati_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  else
    sudo mkinitcpio -P
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

Enter driver to use: " amdd
        case $amdd in
          [1]* )
            yes | sudo pacman -S xf86-video-amdgpu;
            install_mesa_vulkan_drivers;
            yes | sudo pacman -S vulkan-radeon lib32-vulkan-radeon;

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            enable_amdgpu_kms
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            yes | sudo pacman -S xf86-video-ati;
            install_mesa_vulkan_drivers;
            yes | sudo pacman -S vulkan-radeon lib32-vulkan-radeon;

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
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

            generate_nvidia_gpu_config "-lts"
            sudo nvidia-xconfig
            echo NVIDIA drivers installed;
            break 2;;
          * )
            yes | sudo pacman -S nvidia;

            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
            yes | sudo pacman -S nvidia-utils lib32-nvidia-utils;

            generate_nvidia_gpu_config ""
            sudo nvidia-xconfig
            echo NVIDIA drivers installed;
            break 2;;
        esac
      done
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
    [2] ) yes | sudo pacman -S broadcom-wl-dkms; echo "
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

      # update all
      sudo pacman -Syyu

      # theme icon
      # yes | yay -S flat-remix-git
      # sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix
      yes | sudo pacman -S papirus-icon-theme

      # display
      yes | sudo pacman -S feh arandr lxappearance-gtk3 xorg-xbacklight xorg-xrandr xorg-xrdb xorg-xinput

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
      yes | sudo pacman -S gtk2 gtk3

      # mouse cursor theme, notification, system monitor, compositor, image on terminal
      yes | yay -S xcursor-breeze
      yes | sudo pacman -S dunst conky compton w3m
      yes | sudo pacman -S ffmpegthumbnailer

      if [ ! -d /usr/share/icons/Breeze ]; then
        sudo ln -sf /usr/share/icons/xcursor-breeze /usr/share/icons/Breeze
      fi

      # for vifm
      # https://pillow.readthedocs.io/en/stable/installation.html
      yes | sudo pacman -S python-pip
      sudo pip3 install ueberzug
      # yes | sudo pacman -S libimagequant
      # yay -S python-ueberzug --overwrite
      yes | sudo pacman -S poppler
      yes | sudo pacman -S mediainfo
      yes | sudo pacman -S transmission-cli
      yes | sudo pacman -S zip unzip tar xz unrar
      yes | sudo pacman -S catdoc odt2txt docx2txt

      # better desktop locker
      yes | sudo pacman -Rns i3lock
      yes 1 | yay -S i3lock-color --noconfirm

      # terminal-based file viewer
      yes | sudo pacman -S ranger
      yes | sudo pacman -S vifm

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
      yes | sudo pacman -Rns i3-wm
      yes | sudo pacman -S i3-gaps rofi
      yes 1 | yay -S polybar --noconfirm

      # popup calendar
      # sudo pacman -S xdotool
      # yay -S yad

      yes | sudo pacman -S scrot

      yes | sudo pacman -S accountsservice
      yes | sudo pacman -Rns $(pacman -Qtdq)

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

      if [ ! -f $HOME/.riced ]; then
        bash $DIR/../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      # NOTE: needs adjustment for the sake of fedora
      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

      # sed -i "s/# exec --no-startup-id pamac-tray/exec --no-startup-id pamac-tray/g" $HOME/.config/i3/config
      # sed -i "s/# for_window \[class=\"Pamac-manager\"\]/for_window [class=\"Pamac-manager\"]/g" $HOME/.config/i3/config

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
