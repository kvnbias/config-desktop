
#!/bin/bash

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

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
