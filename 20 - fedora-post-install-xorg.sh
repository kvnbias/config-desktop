
#!/bin/bash

os=$(echo -n $(sudo cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
sudo dnf -y upgrade

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

# fonts
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
sudo dnf install -y libinput xorg-x11-drv-libinput --releasever=$fedver


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
        * )
          while true; do
            read -p "Using UEFI [Yn]?   " yn
            case $yn in
              [Nn]* )
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
                break;;
              * )
                sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
                break;;
            esac
          done
          break;;
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
        * )
          while true; do
            read -p "Using UEFI [Yn]?   " yn
            case $yn in
              [Nn]* )
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
                break;;
              * )
                sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
                break;;
            esac
          done
          break;;
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
        * )
          while true; do
            read -p "Using UEFI [Yn]?   " yn
            case $yn in
              [Nn]* )
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
                break;;
              * )
                sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
                break;;
            esac
          done
          break;;
      esac
    done
  fi
}

generate_nvidia_gpu_config() {
  if dnf list installed | grep -q grub2; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
  fi

  if [ -f /etc/default/grub ]; then
    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * )
          while true; do
            read -p "Using UEFI [Yn]?   " yn
            case $yn in
              [Nn]* )
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
                break;;
              * )
                sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg;
                break;;
            esac
          done
          break;;
      esac
    done
  fi
}


while true; do
  read -p "


What GPU are you using? [i]ntel | [a]md | [n]vidia | [v]m | [e]xit   " gpui
  case $gpui in
    [Vv]* )
      sudo dnf install -y xorg-x11-drv-vmware --releasever=$fedver
      echo Driver for VM installed;
      break;;
    [Ii]* )
      sudo dnf install -y xorg-x11-drv-intel --releasever=$fedver

      sudo dnf install -y mesa-dri-drivers mesa-filesystem --releasever=$fedver
      sudo dnf install -y mesa-libEGL mesa-libGL mesa-libGLU --releasever=$fedver
      sudo dnf install -y mesa-libOSMesa mesa-libOpenCL --releasever=$fedver
      sudo dnf install -y mesa-libgbm mesa-libglapi --releasever=$fedver
      sudo dnf install -y mesa-libxatracker --releasever=$fedver

      sudo dnf install -y vulkan-loader --releasever=$fedver
      sudo dnf install -y mesa-vulkan-drivers --releasever=$fedver
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
            sudo dnf install -y xorg-x11-drv-amdgpu --releasever=$fedver

            sudo dnf install -y mesa-dri-drivers mesa-filesystem --releasever=$fedver
            sudo dnf install -y mesa-libEGL mesa-libGL mesa-libGLU --releasever=$fedver
            sudo dnf install -y mesa-libOSMesa mesa-libOpenCL --releasever=$fedver
            sudo dnf install -y mesa-libgbm mesa-libglapi --releasever=$fedver
            sudo dnf install -y mesa-libxatracker --releasever=$fedver

            sudo dnf install -y vulkan-loader --releasever=$fedver
            sudo dnf install -y mesa-vulkan-drivers --releasever=$fedver

            generate_amd_gpu_config
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            sudo dnf install -y xorg-x11-drv-ati --releasever=$fedver

            sudo dnf install -y mesa-dri-drivers mesa-filesystem --releasever=$fedver
            sudo dnf install -y mesa-libEGL mesa-libGL mesa-libGLU --releasever=$fedver
            sudo dnf install -y mesa-libOSMesa mesa-libOpenCL --releasever=$fedver
            sudo dnf install -y mesa-libgbm mesa-libglapi --releasever=$fedver
            sudo dnf install -y mesa-libxatracker --releasever=$fedver

            sudo dnf install -y vulkan-loader --releasever=$fedver
            sudo dnf install -y mesa-vulkan-drivers --releasever=$fedver

            generate_ati_gpu_config
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
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
            sudo dnf install -y xorg-x11-drv-nvidia akmod-nvidia nvidia-xconfig --releasever=$fedver

            generate_nvidia_gpu_config
            sudo nvidia-xconfig
            echo NVIDIA NVEx and newer drivers installed;
            break 2;;
          [2] )
            sudo dnf install -y xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx --releasever=$fedver

            generate_nvidia_gpu_config
            sudo nvidia-xconfig
            echo NVIDIA NVCx and NVDx drivers installed;
            break 2;;
          [3] )
            sudo dnf install -y xorg-x11-drv-nvidia-340xx akmod-nvidia-340xx --releasever=$fedver

            generate_nvidia_gpu_config
            sudo nvidia-xconfig
            echo NVIDIA NV5x, NV8x, NV9x and NVAx drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
  esac
done

# Fallback GPU 
sudo dnf install -y xorg-x11-drv-fbdev --releasever=$fedver
sudo dnf install -y xorg-x11-drv-vesa --releasever=$fedver

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

# fonts
sudo dnf install -y xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi --releasever=$fedver

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
