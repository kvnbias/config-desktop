
#!/bin/bash
DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

yes | sudo pacman -Syyu

while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* ) break;;
    * ) sudo chfn -f "$fn" $(whoami); break;;
  esac
done

# Requirement for graphical env. 
# Defaults to libglvnd (vendor neutral driver). For other drivers,
# check https://wiki.archlinux.org/index.php/Xorg#Driver_installation
yes | sudo pacman -S xorg-server --noconfirm

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.
yes | sudo pacman -S xorg-xinit

## XORG-APPS
# Font compiler for the X server and font server
yes | sudo pacman -S xorg-bdftopcf
# Create an index of X font files in a directory
yes | sudo pacman -S xorg-mkfontdir
# Create an index of scalable font files for X
yes | sudo pacman -S xorg-mkfontscale
# Adjust backlight brightness using RandR extension 
yes | sudo pacman -S xorg-xbacklight
# Utility for modifying keymaps and pointer button mappings in X
yes | sudo pacman -S xorg-xmodmap
# Property displayer for X
yes | sudo pacman -S xorg-xprop
# Utility to configure and test X input devices, such as mouses,
# keyboards, and touchpads.
yes | sudo pacman -S xorg-xinput
# Used to set the size, orientation or reflection of the outputs for a screen.
# For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
yes | sudo pacman -S xorg-xrandr
# X server resource database utility
yes | sudo pacman -S xorg-xrdb
# Display information utility
yes | sudo pacman -S xorg-xdpyinfo

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
yes | sudo pacman -S xf86-input-libinput
# X.Org keyboard input driver
yes | sudo pacman -S xf86-input-keyboard
# X.Org mount input driver
yes | sudo pacman -S xf86-input-mouse

# Fallback GPU driver 1
yes | sudo pacman -S xf86-video-fbdev

# Fallback GPU driver 2
yes | sudo pacman -S xf86-video-vesa

# Install some key packages
yes | sudo pacman -S xorg-fonts-75dpi xorg-fonts-100dpi

sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

if [ "$os" != "manjaro" ]; then
  while true; do
    read -p "Install LTS kernel? [y]es | [n]o   " ilts
    case $ilts in
      [Yy]* ) yes | sudo pacman -S linux-lts linux-lts-headers; break;;
      [Nn]* ) yes | sudo pacman -S linux linux-headers; break;;
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

while true; do
  read -p "This package might installed during installation. Install base-devel [yN]?   " p
  case $p in
    [Yy]* ) yes | sudo pacman -S base-devel --noconfirm; break;;
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
yes | sudo pacman -S gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly

# Browser packages
yes | sudo pacman -S jre-openjdk flashplugin pepper-flash

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* ) yes | sudo pacman -S intel-ucode; break;;
    [Aa]* ) yes | sudo pacman -S amd-ucode; break;;
    * ) echo Invalid input
  esac
done

generate_nvidia_gpu_config() {
  sudo mkdir -p /etc/pacman.d/hooks
  sudo cp -raf "$DIR/../../system-confs/nvidia.hook" "/etc/pacman.d/hooks/nvidia.hook"
  sudo sed -i "s/LINUX_KERNEL/$1/g" "/etc/pacman.d/hooks/nvidia.hook"

  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
    sudo mkinitcpio -P
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
}

enable_amdgpu_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(amdgpu radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(amdgpu radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
}

enable_amdati_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(radeon /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(radeon)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P
    sudo grub-mkconfig -o /boot/grub/grub.cfg
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
    [Ee]* ) break;;
    [Vv]* ) break;;
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

            generate_nvidia_gpu_config "linux-lts"
            sudo nvidia-xconfig
            echo NVIDIA drivers installed;
            break 2;;
          * )
            yes | sudo pacman -S nvidia;

            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
            yes | sudo pacman -S nvidia-utils lib32-nvidia-utils;

            generate_nvidia_gpu_config "linux"
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

  if ! cat /etc/X11/xorg.conf.d/20-intel.conf | grep -q "backlight"; then
    cat "$DIR/../../system-confs/xbacklight.conf" | sudo tee -a "$DIR/../../system-confs/20-intel.conf"
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
    [2] ) yes | sudo pacman -S broadcom-wl-dkms;;
  esac
done

bash $DIR/../../setup-scripts/trrs-prompt.sh

if [ -d /etc/gdm ]; then
  sudo systemctl disable gdm
fi

# Install display manager
yes | sudo pacman -S lightdm
yes | sudo pacman -S noto-fonts
yes | sudo pacman -S lightdm-gtk-greeter
yes | sudo pacman -S lightdm-gtk-greeter-settings
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

bash $DIR/../../setup-scripts/lightdm-unit-alias.sh

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# File manager
yes | sudo pacman -S nautilus
# yes | sudo pacman -S pcmanfm-gtk3

bash "$DIR/desktop-environments/i3.sh"
