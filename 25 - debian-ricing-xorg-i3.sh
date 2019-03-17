
#!/bin/bash

while true; do
  read -p "
If sudo is not enabled during installation (Debian). Login as root (on tty2) then execute the
commands below before proceeding.

apt install -y sudo
groupadd wheel
usermod -aG wheel $(whoami)
usermod -aG sudo $(whoami)
usermod -g wheel $(whoami)
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers

Changes will reflect on the next login. Proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) echo "";;
    * ) break;;
  esac
done

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

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

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

# non-free kernel drivers
sudo apt install -y --no-install-recommends firmware-linux-nonfree

sudo apt install -y build-essential linux-headers-$(uname -r)
sudo apt install -y --no-install-recommends autoconf automake cmake make dkms pkgconf

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
  ' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;


  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
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
' | sudo tee -a /etc/X11/xorg.conf.d/20-radeon.conf;

  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
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
' | sudo tee -a /etc/X11/xorg.conf.d/10-screen.conf;

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
' | sudo tee -a /etc/X11/xorg.conf.d/20-radeon.conf;


  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub-mkconfig -o /boot/grub/grub.cfg; break;;
      esac
    done
  fi
}

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
      sudo apt install -y --no-install-recommends xserver-xorg-video-vmware
      echo Driver for VM installed;
      break;;
    [Ii]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-intel
      # 32bit packages included
      sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx

      sudo apt install -y --no-install-recommends libvulkan1
      sudo apt install -y --no-install-recommends mesa-vulkan-drivers
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
  " amdd
        case $amdd in
          [1]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-amdgpu
            # 32bit packages included
            sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx libva-glx1

            generate_amd_gpu_config
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo apt install -y --no-install-recommends xserver-xorg-video-ati
            # 32bit packages included
            sudo apt install -y libgl1-mesa-dri libgl1-mesa-glx libva-glx1

            sudo apt install -y --no-install-recommends libvulkan1
            sudo apt install -y --no-install-recommends mesa-vulkan-drivers

            generate_ati_gpu_config
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      sudo apt install -y --no-install-recommends xserver-xorg-video-nvidia nvidia-detect
      # 32bit packages included
      sudo apt install -y nvidia-driver libgl1-mesa-dri libgl1-nvidia-glx nvidia-xconfig

      generate_nvidia_gpu_config
      sudo nvidia-xconfig
      echo NVIDIA drivers installed;
      break;;
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
  ' | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf;
    echo Added intel_backlight;
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


if [ -d /etc/gdm ]; then
  # use lightdm instead
  sudo systemctl disable gdm
fi

# Greeter
sudo apt install -y --no-install-recommends lightdm slick-greeter
sudo apt install -y --no-install-recommends fonts-noto
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=slick-greeter/g' /etc/lightdm/lightdm.conf

if cat /usr/lib/systemd/system/lightdm.service | grep -q 'Alias=display-manager.service'; then
  echo 'Alias already exists'
else
  if cat /usr/lib/systemd/system/lightdm.service | grep -q '\[Install\]'; then
    echo 'Install already exists'
  else
    echo '[Install]' | sudo tee -a /usr/lib/systemd/system/lightdm.service
  fi

  echo 'Alias=display-manager.service' | sudo tee -a /usr/lib/systemd/system/lightdm.service
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
fi

sudo cp $HOME/.Xresources /root/.Xresources

mainCWD=$(pwd)
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
      git clone --recurse-submodules https://github.com/daniruiz/flat-remix.git
      cd flat-remix

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      sudo mkdir -p /usr/share/icons && sudo cp -raf Flat-Remix* /usr/share/icons/
      sudo ln -sf /usr/share/icons/Flat-Remix-Blue /usr/share/icons/Flat-Remix
      cd /tmp

      # gtk theme
      git clone --recurse-submodules https://github.com/daniruiz/flat-remix-gtk.git
      cd flat-remix-gtk

      git fetch --tags
      tag=$(git describe --tags `git rev-list --tags --max-count=1`)

      if [ ${#tag} -ge 1 ]; then
        git checkout $tag
      fi

      git tag -f "git-$(git rev-parse --short HEAD)"
      sudo mkdir -p /usr/share/themes && sudo cp -raf Flat-Remix-GTK* /usr/share/themes/
      cd /tmp

      # display
      sudo apt install -y --no-install-recommends nitrogen arandr lxappearance xbacklight x11-xserver-utils

      sudo apt install -y --no-install-recommends notification-daemon
#       echo "
# [D-BUS Service]
# Name=org.freedesktop.Notifications
# Exec=/usr/libexec/notification-daemon
# " | sudo tee /usr/share/dbus-1/services/org.freedesktop.Notifications.service

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

      # MANUAL: PulseAudio Applet. Some are already installed
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

      sudo apt remove -y libglib2.0-dev libgtk-3-dev libnotify-dev
      sudo apt remove -y libpulse-dev libx11-dev

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      # network manager
      sudo apt install -y --no-install-recommends network-manager network-manager-gnome
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


