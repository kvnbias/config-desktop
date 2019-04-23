

#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))


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
