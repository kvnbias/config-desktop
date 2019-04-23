
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
