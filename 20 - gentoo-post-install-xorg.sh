
#!/bin/bash
# NOTE this script is only tested in my machines

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

