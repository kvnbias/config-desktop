
#!/bin/bash
# NOTE this script is only tested in my machines

# xorg
sudo emerge x11-base/xorg-server

# Executes .xinitrc file that determines what desktop environment or
# window tiling manager to use.

## XORG-APPS
# bdftopcf    - Font compiler for the X server and font server.
sudo emerge x11-apps/bdftopcf
# mkfontdir   - Create an index of X font files in a directory.
sudo emerge x11-apps/mkfontdir
# mkfontscale - Create an index of scalable font files for X.
sudo emerge x11-apps/mkfontscale
# xbacklight - Adjust backlight brightness using RandR extension .
sudo emerge x11-apps/xbacklight
# xmodmap - Utility for modifying keymaps and pointer button mappings in X.
sudo emerge x11-apps/xmodmap
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
sudo emerge x11-apps/xrandr
# xrdb    - X server resource database utility.
sudo emerge x11-apps/xrdb
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
sudo emerge x11-apps/xinput
# xprop    - Property displayer for X.
sudo emerge x11-apps/xprop
# xdpyinfo - Display information utility.
sudo emerge x11-apps/xdpyinfo

## XORG-DRIVERS
# Provide advanced support for touch (multitouch and gesture) features
# of touchpads and touchscreens.
sudo emerge x11-drivers/xf86-input-libinput
sudo emerge x11-drivers/xf86-input-keyboard x11-drivers/xf86-input-mouse

# Fallback GPU 
sudo emerge x11-drivers/xf86-video-fbdev x11-drivers/xf86-video-vesa

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

