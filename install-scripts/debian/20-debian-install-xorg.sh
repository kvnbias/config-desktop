#!/bin/bash
# NOTE this script is only tested in my machines
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/debian-sudo-prompt.sh "$os"
bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* ) break;;
    * ) sudo chfn -f "$fn" $(whoami); break;;
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

sudo apt install -y --no-install-recommends policykit-1-gnome

# Sound
sudo apt install -y --no-install-recommends alsa-utils

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
sudo apt install -y --no-install-recommends gstreamer1.0-x gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-vaapi
sudo apt install -y --no-install-recommends gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

sudo apt install -y --no-install-recommends openjdk-11-jdk
sudo apt install -y browser-plugin-freshplayer-pepperflash

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* ) sudo apt install -y --no-install-recommends intel-microcode; break;;
    [Aa]* ) sudo apt install -y --no-install-recommends amd64-microcode; break;;
    * ) echo Invalid input
  esac
done

## GPU DRIVERS
generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
    sudo grub-mkconfig -o /boot/grub/grub.cfg
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
    [Ee]* ) break;;
    [Vv]* ) break;;
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

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backlight"; then
    cat "$DIR/../../system-confs/xbacklight.conf" | sudo tee -a "$DIR/../../system-confs/20-intel.conf"
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
      sudo modprobe wl;;
  esac
done

bash $DIR/../../setup-scripts/trrs-prompt.sh

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

bash $DIR/../../setup-scripts/lightdm-unit-alias.sh

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# File manager
sudo apt install -y --no-install-recommends nautilus

bash "$DIR/desktop-environments/i3.sh"
