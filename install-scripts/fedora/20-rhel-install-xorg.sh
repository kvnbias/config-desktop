
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

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

sudo dnf install -y libuser util-linux-user --releasever=$fedver
while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* ) break;;
    * ) sudo chfn -f "$fn" $(whoami); break;;
  esac
done

[ ! cat /etc/dnf/fnd.conf | grep -q 'metadata_expire' ] && echo 'metadata_expire=86400' | sudo tee -a /etc/dnf/dnf.conf
[ ! cat /etc/dnf/dnf.conf | grep -q 'max_parallel_downloads' ] && echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf

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
sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

# selinux utils
sudo dnf install -y checkpolicy policycoreutils-python-utils --releasever=$fedver
sudo dnf install -y gcc gcc-c++ autoconf automake cmake make dkms pkgconfig bzip2 --releasever=$fedver

sudo dnf install -y at
sudo systemctl enable atd
sudo systemctl start atd

sudo dnf install -y polkit-gnome --releasever=$fedver

# Sound
sudo dnf install -y alsa-utils --releasever=$fedver

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
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
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

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backlight"; then
    cat "$DIR/../../system-confs/xbacklight.conf" | sudo tee -a "$DIR/../../system-confs/20-intel.conf"
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
      sudo modprobe wl;;
  esac
done

bash $DIR/../../setup-scripts/trrs-prompt.sh

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

bash $DIR/../../setup-scripts/lightdm-unit-alias.sh

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# File manager
sudo dnf install -y nautilus --releasever=$fedver

bash "$DIR/desktop-environments/i3.sh"
