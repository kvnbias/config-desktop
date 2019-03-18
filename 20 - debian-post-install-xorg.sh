#!/bin/bash
# NOTE this script is only tested in my machines

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
# xinput  - Utility to configure and test X input devices, such as mouses,
#           keyboards, and touchpads.
# xrandr  - Used to set the size, orientation or reflection of the outputs for a screen.
#           For multiple monitors, visit https://wiki.archlinux.org/index.php/Multihead
# xrdb    - X server resource database utility.
sudo apt install -y --no-install-recommends x11-xserver-utils
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

