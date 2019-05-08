
#!/bin/bash
# NOTE this script is only tested in my machines

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

bash $DIR/../../setup-scripts/multi-boot-prompt.sh
bash $DIR/../../setup-scripts/boot-startup-prompt.sh "$os"

while true; do
  read -p "Enter full name or [s]kip?   " fn
  case $fn in
    [Ss]* ) break;;
    * ) sudo chfn -f "$fn" $(whoami); break;;
  esac
done

install_packages() {
  while true; do
    read -p "
NOTE: Sometimes you need to merge the configs before the packages get installed

Target: $1

[1] Install
[2] Sync
[3] Update world
[4] Auto merge configs
[5] Execute command
[6] Exit

Action:   " ipa
    case $ipa in
      1 ) sudo emerge --ask $1;;
      2 ) sudo emerge --sync;;
      3 ) sudo emerge --ask --verbose --update --deep --newuse @world;;
      4 ) yes | sudo etc-update --automode -3;;
      5 )
        while true; do
          read -p "Command to execute or [e]xit:   " cmd
          case $cmd in
            [Ee] ) break;;
            * ) $cmd;;
          esac
        done;;
      6 ) break;;
    esac
  done
}

# xorg
sudo touch /etc/portage/package.use/xorg-server
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
    [Vv]* )
      echo "VIDEO_CARDS=\"virtualbox vmware vesa fbdev\"" | sudo tee -a /etc/portage/make.conf;
      echo "media-libs/mesa classic dri3 egl gallium gbm gles2 gles1 osmesa vaapi" | sudo tee -a /etc/portage/package.use/xorg-server
      break;;
    [Ii]* )
      echo "VIDEO_CARDS=\"intel i915 i965 vesa fbdev\"" | sudo tee -a /etc/portage/make.conf;
      echo "x11-drivers/xf86-video-intel dri dri3" | sudo tee /etc/portage/package.use/xf86-video-intel;
      echo "media-libs/mesa classic dri3 egl gallium gbm gles2 gles1 osmesa vaapi vulkan" | sudo tee -a /etc/portage/package.use/xorg-server
      break;;
    [Aa]* )
      echo "VIDEO_CARDS=\"amdgpu radeon radeonsi vesa fbdev\"" | sudo tee -a /etc/portage/make.conf;
      echo "media-libs/mesa classic dri3 egl gallium gbm gles2 d3d9 gles1 opencl osmesa vaapi vulkan" | sudo tee -a /etc/portage/package.use/xorg-server
      break;;
    [Nn]* )
      echo "VIDEO_CARDS=\"nvidia nv vesa fbdev\"" | sudo tee -a /etc/portage/make.conf;
      echo "media-libs/mesa classic dri3 egl gallium gbm gles2 gles1 opencl osmesa vaapi" | sudo tee -a /etc/portage/package.use/xorg-server
      break;;
  esac
done

echo "INPUT_DEVICES=\"keyboard libinput mouse joystick\"" | sudo tee -a /etc/portage/make.conf
echo "
x11-libs/libXfont2 truetype
x11-libs/libva vdpau
" | sudo tee -a /etc/portage/package.use/xorg-server
install_packages "x11-base/xorg-server"

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.
install_packages "x11-apps/xinit"

## XORG-APPS
# bdftopcf    - Font compiler for the X server and font server.
install_packages "x11-apps/bdftopcf"
# mkfontdir   - Create an index of X font files in a directory.
install_packages "x11-apps/mkfontdir"
# mkfontscale - Create an index of scalable font files for X.
install_packages "x11-apps/mkfontscale"
# xbacklight - Adjust backlight brightness using RandR extension .
install_packages "x11-apps/xbacklight"
# xmodmap - Utility for modifying keymaps and pointer button mappings in X.
install_packages "x11-apps/xmodmap"
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
install_packages "x11-apps/xrandr"
# xrdb    - X server resource database utility.
install_packages "x11-apps/xrdb"
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
install_packages "x11-apps/xinput"
# xprop    - Property displayer for X.
install_packages "x11-apps/xprop"
# xdpyinfo - Display information utility.
echo "x11-apps/xdpyinfo xinerama" | sudo tee /etc/portage/package.use/xdpyinfo
install_packages "x11-apps/xdpyinfo"

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
install_packages "x11-drivers/xf86-input-libinput"
install_packages "x11-drivers/xf86-input-keyboard x11-drivers/xf86-input-mouse"

# Fallback GPU 
install_packages "x11-drivers/xf86-video-fbdev x11-drivers/xf86-video-vesa"
install_packages "media-libs/fontconfig"

if cat /etc/portage/make.conf | grep -q 'USE='; then
  if ! cat /etc/portage/make.conf | grep -q 'udisks'; then
    sudo sed -i "s/USE=\"/USE=\"udisks /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'alsa pulseaudio'; then
    sudo sed -i "s/USE=\"/USE=\"alsa pulseaudio /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'gtk gtk3'; then
    sudo sed -i "s/USE=\"/USE=\"gtk gtk3 /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'jpeg jpeg2k jpg png truetype'; then
    sudo sed -i "s/USE=\"/USE=\"jpeg jpeg2k jpg png truetype /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'ffmpeg'; then
    sudo sed -i "s/USE=\"/USE=\"ffmpeg -libav /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'systemd'; then
    sudo sed -i "s/USE=\"/USE=\"systemd /g" /etc/portage/make.conf
  fi

  if ! cat /etc/portage/make.conf | grep -q 'X'; then
    sudo sed -i "s/USE=\"/USE=\"X /g" /etc/portage/make.conf
  fi
else
  echo "USE=\"X systemd alsa pulseaudio udisks ffmpeg -libav gtk gtk3 jpeg jpeg2k jpg png truetype\"" | sudo tee -a /etc/portage/make.conf
fi

sudo cp -raf $DIR/../../system-confs/initial-package.use /etc/portage/package.use/flags

if [ ! -f /etc/X11/xorg.conf ];then
  sudo touch /etc/X11/xorg.conf;
fi

sudo cp -raf "$DIR/../../system-confs/xorg.conf" "/etc/X11/xorg.conf"

install_packages "sys-kernel/linux-firmware sys-kernel/linux-headers"
install_packages "gnome-extra/polkit-gnome"

install_packages "sys-process/at"
sudo systemctl enable atd
sudo systemctl start atd

install_packages "media-sound/alsa-utils"

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

install_packages "media-libs/gstreamer media-plugins/gst-plugins-libav media-plugins/gst-plugins-vaapi"
install_packages "media-libs/gst-plugins-base media-libs/gst-plugins-bad media-libs/gst-plugins-good media-libs/gst-plugins-ugly"

install_packages "dev-java/openjdk-bin"
install_packages "www-plugins/freshplayerplugin"

while true; do
  read -p "What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* ) install_packages "sys-firmware/intel-microcode"; break;;
    [Aa]* ) break;;
    * ) echo Invalid input
  esac
done

## GPU DRIVERS
generate_nvidia_gpu_config() {
  if [ -f /etc/default/grub ]; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /g' /etc/default/grub;
    sudo grub-mkconfig -o /boot/grub/grub.cfg;
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
    [Ee]* ) break;;
    [Vv]* )
      while true; do
        read -p "
Enter virtual machine:

[1] Virtualbox
[2] VMware
[e] Exit

Action:   " vma
        case $vma in
          [Ee] ) break;;
          1 ) install_packages "x11-drivers/xf86-video-vboxvideo"; break 2;;
          2 ) install_packages "x11-drivers/xf86-video-vmware"; break 2;;
        esac
      done;;
    [Ii]* )
      install_packages "x11-drivers/xf86-video-intel"
      install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

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

Driver:   " amdd
        case $amdd in
          [1]* )
            install_packages "x11-drivers/xf86-video-amdgpu"
            install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            sudo cp -raf "$DIR/../../system-confs/10-screen.conf"     "/etc/X11/xorg.conf.d/10-screen.conf"
            echo AMDGPU drivers installed;
            break 2;;
          [2]* )
            install_packages "x11-drivers/xf86-video-ati"
            install_packages "media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools"

            sudo cp -raf "$DIR/../../system-confs/20-radeon-ati.conf" "/etc/X11/xorg.conf.d/20-radeon.conf"
            echo ATI drivers installed;
            break 2;;
          [Ee]* ) break 2;;
          * ) echo Invalid input
        esac
      done;;
    [Nn]* )
      install_packages "x11-drivers/xf86-video-nv"
      install_packages "x11-drivers/nvidia-drivers media-libs/vulkan-loader dev-util/vulkan-tools"

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

install_packages "x11-libs/libva-vdpau-driver x11-libs/libvdpau x11-misc/vdpauinfo"

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
      install_packages "net-wireless/broadcom-sta net-wireless/wireless-tools"
      sudo modprobe wl

      if [ -f /etc/modules-load.d/networking.conf ]; then
        echo 'wl' | sudo tee /etc/modules-load.d/networking.conf
      else
        echo 'wl' | sudo tee -a /etc/modules-load.d/networking.conf
      fi
      ;;
  esac
done

bash $DIR/../../setup-scripts/trrs-prompt.sh

if [ -d /etc/gdm ]; then
  sudo systemctl disable gdm
fi

install_packages "x11-misc/lightdm x11-misc/lightdm-gtk-greeter media-fonts/noto"
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

install_packages "gnome-base/nautilus"

bash "$DIR/desktop-environments/i3.sh"
