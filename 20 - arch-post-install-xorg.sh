
#!/bin/bash

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
' | sudo tee -a /etc/X11/xorg.conf

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
yes | sudo pacman -S xf86-input-libinput
# X.Org keyboard input driver
yes | sudo pacman -S xf86-input-keyboard
# X.Org mount input driver
yes | sudo pacman -S xf86-input-mouse

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

}

generate_nouveau_gpu_config() {
  if [ ! -f /etc/X11/xorg.conf.d/20-nouveau.conf ];then
    sudo touch /etc/X11/xorg.conf.d/20-nouveau.conf;
  fi

  sudo sed -i 's/blacklist/#blacklist/g' /usr/lib/modprobe.d/nvidia-lts.conf
  sudo sed -i 's/blacklist/#blacklist/g' /usr/lib/modprobe.d/nvidia.conf

  echo '
Section "Device"
  Identifier "Nvidia card"
  Driver "nouveau"
EndSection
  ' | sudo tee -a /etc/X11/xorg.conf.d/20-nouveau.conf;

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
  " | sudo tee -a /etc/pacman.d/hooks/nvidia.hook;

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

enable_nouveau_kms() {
  sudo sed -i 's/MODULES=(/MODULES=(nouveau /g' /etc/mkinitcpio.conf;
  sudo sed -i 's/MODULES=""/MODULES=(nouveau)/g' /etc/mkinitcpio.conf;

  if [ -f /etc/default/grub ]; then
    sudo mkinitcpio -P;
  fi
}

while true; do
  read -p "


What GPU are you using? [i]ntel | [a]md | [n]vidia | [v]m | [e]xit   " gpui
  case $gpui in
    [Vv]* )
      yes | sudo pacman -S xf86-video-vmware;
      echo Driver for VM installed;
      break;;
    [Ii]* )
      yes | sudo pacman -S xf86-video-intel mesa lib32-mesa;
      yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
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
  " amdd
        case $amdd in
          [1]* )
            yes | sudo pacman -S xf86-video-amdgpu mesa lib32-mesa;
            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
            yes | sudo pacman -S vulkan-radeon lib32-vulkan-radeon;
            generate_amd_gpu_config
            enable_amdgpu_kms
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            yes | sudo pacman -S xf86-video-ati mesa lib32-mesa;
            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;
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
        read -p "

What driver to use? [o]pen source | [p]roprietary | [e]xit   ?" oscs
        case $oscs in
          [Oo]* )
            yes | sudo pacman -S xf86-video-nouveau mesa lib32-mesa;
            yes | sudo pacman -S vulkan-icd-loader lib32-vulkan-icd-loader;

            yes | sudo pacman -S nvidia-lts;
            yes | sudo pacman -S nvidia;
            
            generate_nouveau_gpu_config
            enable_nouveau_kms
            echo Nouveau drivers installed;
            break 2;;
          [Pp]* )
            while true; do
              echo "

Your GPU: ";
              lspci -k | grep -A 2 -E "(VGA|3D)";
              read -p "
  
  
  What driver to use?
  Check: https://nouveau.freedesktop.org/wiki/CodeNames/
  [1] GeForce 600-900 and 10 series cards and newer (NVEx and newer)
  [2] GeForce 400/500 series cards (NVCx and NVDx)
  [3] GeForce 8/9, ION and 100-300 series cards (NV5x, NV8x, NV9x and NVAx)
  [e]xit
  " und
              case $und in
                [1] )
                  yes | sudo pacman -S nvidia-lts;
                  yes | sudo pacman -S nvidia;

                  yes | sudo pacman -S nvidia-utils lib32-nvidia-utils;
                  generate_nvidia_gpu_config
                  sudo nvidia-xconfig
                  echo NVIDIA NVEx and newer drivers installed;
                  break 3;;
                [2] )
                  yes | sudo pacman -S nvidia-390xx-lts;
                  yes | sudo pacman -S nvidia-390xx;

                  yes | sudo pacman -S nvidia-390xx-utils lib32-nvidia-390xx-utils;
                  generate_nvidia_gpu_config
                  sudo nvidia-xconfig
                  echo NVIDIA NVCx and NVDx drivers installed;
                  break 3;;
                [3] )
                  yes | sudo pacman -S nvidia-340xx-lts;
                  yes | sudo pacman -S nvidia-340xx;

                  yes | sudo pacman -S nvidia-340xx-utils lib32-nvidia-340xx-utils;
                  generate_nvidia_gpu_config
                  sudo nvidia-xconfig
                  echo NVIDIA NV5x, NV8x, NV9x and NVAx drivers installed;
                  break 3;;
                [Ee]* ) break 3;;
                * ) echo Invalid input
              esac
            done;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
  esac
done

# Fallback GPU driver 1
yes | sudo pacman -S xf86-video-fbdev

# Fallback GPU driver 2
yes | sudo pacman -S xf86-video-vesa

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

# Install some key packages
yes | sudo pacman -S xorg-fonts-75dpi xorg-fonts-100dpi
yes | sudo pacman -S ttf-dejavu

echo '

########################################
########################################
###                                  ###
###    XORG INITIAL INSTALLATION     ###
###    COMPLETE. INSTALL YOUR        ###
###    DESKTOP ENVIRONMENT AND       ###
###    DISPLAY MANAGER NEXT...       ###
###                                  ###
########################################
########################################

'
