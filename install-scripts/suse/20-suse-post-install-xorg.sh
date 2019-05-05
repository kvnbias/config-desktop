
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

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

sudo zypper refresh
sudo zypper -n update

# xorg
sudo zypper -n install --no-recommends xorg-x11-server

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.
sudo zypper -n install --no-recommends xinit

## XORG-APPS
# bdftopcf    - Font compiler for the X server and font server.
sudo zypper -n install --no-recommends bdftopcf
# mkfontdir   - Create an index of X font files in a directory.
# mkfontscale - Create an index of scalable font files for X.
sudo zypper -n install --no-recommends mkfontscale
# xdpyinfo    - Display information utility.
sudo zypper -n install --no-recommends xdpyinfo
# xbacklight - Adjust backlight brightness using RandR extension .
sudo zypper -n install --no-recommends xbacklight
# xmodmap - Utility for modifying keymaps and pointer button mappings in X.
sudo zypper -n install --no-recommends xmodmap
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
sudo zypper -n install --no-recommends xinput
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
sudo zypper -n install --no-recommends xrandr
# xrdb    - X server resource database utility.
sudo zypper -n install --no-recommends xrdb
# xprop - Property displayer for X.
sudo zypper -n install --no-recommends xprop

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
sudo zypper -n install --no-recommends libinput10 xf86-input-libinput

# Fallback GPU 
sudo zypper -n install --no-recommends xf86-video-fbdev
sudo zypper -n install --no-recommends xf86-video-vesa

# fonts
sudo zypper -n install --no-recommends xorg-x11-fonts
sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

sudo zypper -n install --no-recommends bc gcc gcc-c++ autoconf automake cmake make dkms bzip2
sudo zypper -n install --no-recommends libuser pkgconf

sudo zypper -n install --no-recommends at
sudo systemctl enable atd
sudo systemctl start atd

sudo zypper -n update

sudo zypper -n install --no-recommends polkit-gnome

# Sound
sudo zypper -n install --no-recommends alsa-utils

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

bash $DIR/../../setup-scripts/change-packman-mirror.sh

hasPackman=false
if zypper ls | grep -q 'packman-essentials'; then
  hasPackman=true
fi

# Gstreamer
sudo zypper -n install --no-recommends gstreamer gstreamer-plugins-vaapi
sudo zypper -n install --no-recommends gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-good-extra
sudo zypper -n install --no-recommends gstreamer-plugins-good-gtk

sudo zypper -n install --no-recommends gstreamer-plugins-bad gstreamer-plugins-libav gstreamer-plugins-ugly
if [ "$hasPackman" = true ]; then
  sudo zypper -n remove gstreamer-plugins-bad gstreamer-plugins-libav gstreamer-plugins-ugly
  sudo zypper -n install --no-recommends -r packman-essentials gstreamer-plugins-bad gstreamer-plugins-ugly
  sudo zypper -n install --no-recommends -r packman-essentials gstreamer-plugins-libav
fi

## Flash Repo
sudo zypper ar -cfp 90 http://linuxdownload.adobe.com/linux/x86_64/ adobe
sudo zypper inr -r adobe
sudo zypper install -r adobe adobe-release-x86_64
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
sudo zypper -n install --no-recommends flash-plugin

sudo zypper -n install --no-recommends java-12-openjdk

if [ "$hasPackman" = true ]; then
  sudo zypper -n install --no-recommends -r packman-essentials flash-player-ppapi
fi

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* ) sudo zypper -n install --no-recommends ucode-intel; break;;
    [Aa]* ) sudo zypper -n install --no-recommends ucode-amd; break;;
    * ) echo Invalid input
  esac
done

generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
}

install_mesa_vulkan_drivers() {
  sudo zypper -n install --no-recommends Mesa
  sudo zypper -n install --no-recommends Mesa-dri
  sudo zypper -n install --no-recommends Mesa-libEGL1
  sudo zypper -n install --no-recommends Mesa-libGL1
  sudo zypper -n install --no-recommends Mesa-libd3d
  sudo zypper -n install --no-recommends Mesa-libglapi0
  sudo zypper -n install --no-recommends libOSMesa8

  sudo zypper -n install --no-recommends Mesa-32bit
  sudo zypper -n install --no-recommends Mesa-dri-32bit
  sudo zypper -n install --no-recommends Mesa-libEGL1-32bit
  sudo zypper -n install --no-recommends Mesa-libGL1-32bit
  sudo zypper -n install --no-recommends Mesa-libd3d-32bit
  sudo zypper -n install --no-recommends Mesa-libglapi0-32bit
  sudo zypper -n install --no-recommends libOSMesa8-32bit

  sudo zypper -n install --no-recommends Mesa-libGLESv1_CM1 Mesa-libGLESv2-2 Mesa-libOpenCL

  sudo zypper -n install --no-recommends libvulkan1
  sudo zypper -n install --no-recommends libvulkan1-32bit

  sudo zypper -n install --no-recommends vulkan-headers vulkan-tools
  sudo zypper -n install --no-recommends Mesa-libVulkan-devel
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
      sudo zypper -n install --no-recommends xf86-video-intel
      install_mesa_vulkan_drivers
      sudo zypper -n install --no-recommends libvulkan_intel
      sudo zypper -n install --no-recommends libvulkan_intel-32bit

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

Enter driver:   " amdd
        case $amdd in
          [1]* )
            sudo zypper -n install --no-recommends xf86-video-amdgpu
            install_mesa_vulkan_drivers
            sudo zypper -n install --no-recommends libvulkan_radeon
            sudo zypper -n install --no-recommends libvulkan_radeon-32bit

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo zypper -n install --no-recommends xf86-video-ati
            install_mesa_vulkan_drivers
            sudo zypper -n install --no-recommends libvulkan_radeon
            sudo zypper -n install --no-recommends libvulkan_radeon-32bit

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      sudo zypper -n install --no-recommends xf86-video-nv

      sudo zypper ar -cfp 90 https://download.nvidia.com/opensuse/tumbleweed nvidia
      sudo zypper inr -r nvidia

      sudo zypper -n install --no-recommends x11-video-nvidiaG05 nvidia-glG05 nvidia-gfxG05-kmp-default nvidia-computeG05

      sudo zypper -n install --no-recommends libvulkan1
      sudo zypper -n install --no-recommends libvulkan1-32bit
      sudo zypper -n install --no-recommends vulkan-headers vulkan-tools

      generate_nvidia_gpu_config
      echo NVIDIA drivers installed;
      break;;
  esac
done

## Adding intel backlight
if ls /sys/class/backlight | grep -q "^intel_backlight$"; then
  if [ ! -d /etc/X11/xorg.conf.d ];then
    sudo mkdir -p /etc/X11/xorg.conf.d
  fi

  if [ !$(ls /etc/X11/xorg.conf.d | grep -q ^20-intel.conf$) ];then
    sudo touch /etc/X11/xorg.conf.d/20-intel.conf;
  fi

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backligaht"; then
    cat "$DIR/../../system-confs/xbacklight.conf" | sudo tee -a "$DIR/../../system-confs/20-intel.conf"
    echo Added intel_backlight;
  fi
fi

## Hardware acceleration drivers installation
sudo zypper -n install --no-recommends Mesa-libva libvdpau_va_gl1 libvdpau_va_gl1-32bit
sudo zypper -n install --no-recommends libgstvdpau
sudo zypper -n install --no-recommends libva-vdpau-driver libvdpau1
if [ "$hasPackman" = true ]; then
  sudo zypper -n remove libgstvdpau
  sudo zypper -n install --no-recommends -r packman-essentials libgstvdpau
fi

## Network
sudo zypper -n install --no-recommends kernel-devel
while true; do
  sudo lspci -nnk | grep 0280 -A3
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
    [1] ) sudo lspci | grep Network;;
    [2] )
      if [ "$hasPackman" = true ]; then
        sudo zypper -n install --no-recommends -r packman-essentials broadcom-wl;
        sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
        sudo modprobe wl
      else
        sudo modprobe b43
      fi
      ;;
  esac
done

bash $DIR/../../setup-scripts/trrs-prompt.sh

if [ -d /etc/gdm ]; then
  # use lightdm instead
  sudo systemctl disable gdm
fi

# Greeter
# sudo zypper -n install --no-recommends lightdm
sudo zypper -n install --no-recommends noto-mono-fonts noto-sans-fonts
sudo zypper -n install --no-recommends lightdm-gtk-greeter-branding-upstream

# sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
# sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# File manager
sudo zypper -n install --no-recommends nautilus

bash "$DIR/desktop-environments/i3.sh"
