#!/bin/bash
# NOTE this script is only tested in my machines

sudo rm /arch-install

while true; do
  read -p "


Install LTS kernel? [y]es | [n]o   " ilts
  case $ilts in
    [Yy]* )
      yes | sudo pacman -S linux-lts linux-lts-headers
      break;;
    [Nn]* )
      yes | sudo pacman -S linux linux-headers
      break;;
    * ) echo Invalid input
  esac
done

sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
sudo sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/g' /etc/default/grub

cpu=intel
while true; do
  read -p "


What CPU are you using? [i]ntel | [a]md   " cpui
  case $cpui in
    [Ii]* ) cpu=intel; break;;
    [Aa]* ) cpu=amd; break;;
    * ) echo Invalid input
  esac
done

if [ "$cpu" == "intel" ]; then
  yes | sudo pacman -S intel-ucode;
else
  yes | sudo pacman -S amd-ucode;
fi

while true; do
  read -p "Update GRUB [Yn]?   " updgr
  case $updgr in
    [Nn]* )
      break;;
    * )
      sudo grub-mkconfig -o /boot/grub/grub.cfg;
      break;;
  esac
done

while true; do
  read -p "


Would you like to increase AUR threads [Yn]?   " aurt
  case $aurt in
    [Nn]* ) break;;
    * )
      while true; do
        read -p "How many threads you would like to add or [e]xit   " numt
        case $numt in
          [Ee]* ) break;;
          * )
            if [[ $numt =~ ^[0-9]+$ ]]; then
              sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$numt\"/g" /etc/makepkg.conf;
              echo Threads increased to $numt;
              break;
            else
              echo Invalid input;
              break;
            fi
        esac
      done;;
  esac
done

# install AUR helper: yay
git clone https://aur.archlinux.org/yay.git
cd yay
yes | makepkg --syncdeps --install
yes | yay -Syu
cd ..
rm -rf yay

# Remove orphan packages from yay
yes | sudo pacman -Rns $(pacman -Qtdq)

## Enabling multilib
# Contains 32-bit software and libraries that can be
# used to run and build 32-bit applications on 64-bit installs (e.g. wine, steam, etc). 
sudo sed -i ":a;N;\$!ba;s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/g" /etc/pacman.conf;
sudo pacman -Sy

# Activate numlock on boot
yes | sudo pacman -S numlockx

# Create user dirs
yes | sudo pacman -S xdg-user-dirs
xdg-user-dirs-update

# Hibernation
while true; do
  read -p "


Do you like to enable hibernation [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        sudo fdisk -l;
        read -p "What device to use (e.g. /dev/sdXn) or [e]xit   ?   " dvc
        case $dvc in
          [Ee]* ) break;;
          * )
            sudo sed -i "s~GRUB_CMDLINE_LINUX_DEFAULT=\"~GRUB_CMDLINE_LINUX_DEFAULT=\"resume=$dvc ~g" /etc/default/grub
            break 2;;
        esac
      done;;
  esac
done

while true; do
  read -p "Update GRUB [Yn]?   " updgr
  case $updgr in
    [Nn]* )
      break;;
    * )
      sudo mkinitcpio -P;
      sudo grub-mkconfig -o /boot/grub/grub.cfg;
      break;;
  esac
done

# Sound
yes | sudo pacman -S alsa-utils

amixer sset "Master" unmute
amixer sset "Speaker" unmute
amixer sset "Headphone" unmute

amixer sset "Master" 100%
amixer sset "Speaker" 100%
amixer sset "Headphone" 100%
amixer sset "Mic Boost" 100%

# Gstreamer
yes | sudo pacman -S gstreamer
yes | sudo pacman -S clutter-gst
yes | sudo pacman -S gst-libav
yes | sudo pacman -S gst-plugins-bad
yes | sudo pacman -S gst-plugins-base
yes | sudo pacman -S gst-plugins-base-libs
yes | sudo pacman -S gst-plugins-good
yes | sudo pacman -S gst-plugins-ugly

# Browser packages
yes | sudo pacman -S jre-openjdk flashplugin pepper-flash
yes | yay -S ttf-ms-fonts --noconfirm

yes | sudo pacman -S acpid

sudo systemctl enable acpid

## Hardware acceleration drivers installation
gpu=;
while true; do
  echo "Your GPU: ";
  lspci -k | grep -A 2 -E "(VGA|3D)";
  read -p "


What GPU are you using? [i]ntel | [a]md | [n]vidia | [v]m | [e]xit   " gpui
  case $gpui in
    [Ii]* )
      while true; do
        read -p "

Model?
Check: https://en.wikipedia.org/wiki/Intel_Graphics_Technology
[1] Broadwell and newer
[2] GMA 4500 series and newer GPUs up to Coffee Lake
[e]xit
    " ihva
        case $ihva in
          [1] )
            gpu=intel;
            yes | sudo pacman -S intel-media-driver;
            break 2;;
          [2] )
            gpu=intel;
            yes | sudo pacman -S libva-intel-driver intel-media-driver;
            break 2;;
          [Ee]* ) break;;
          * ) echo Invalid input;
        esac
      done;;
    [Aa]* )
      while true; do
        read -p "

Model?
Check: https://en.wikipedia.org/wiki/Template:AMD_graphics_API_support
[1] Radeon R300 and newer
[2] Radeon HD 2000 and newer
[e]xit
    " ihva
        case $ihva in
          [1] )
            gpu=amd;
            yes | sudo pacman -S mesa-vdpau lib32-mesa-vdpau;
            break 2;;
          [2] )
            gpu=amd;
            yes | sudo pacman -S mesa-vdpau lib32-mesa-vdpau;
            yes | sudo pacman -S libva-mesa-driver lib32-libva-mesa-driver;
            break 2;;
          [Ee]* ) break;;
          * ) echo Invalid input;
        esac
      done;;
    [Nn]* )
      gpu=nvidia;
      yes | sudo pacman -S nvidia-utils libva-mesa-driver mesa-vdpau;
      yes | yay -S nouveau-fw;
      break;;
    [Vv]* )
      gpu=vm;
      break;;
    [Ee]* ) break;;
    * ) echo Invalid input
  esac
done

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
[3] Realtek R8168
[4] Realtek RTL8188EUS (RTL8188EUS, RTL8188ETV)
[5] Realtek RTL8188CUS (8188C, 8192C) 
[m] Modprobe a module
[e] Exit
  " wd
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
    [2] ) sudo pacman -S broadcom-wl-dkms; echo "
Installation done...
";;
    [3] ) sudo pacman -S r8168; echo "
Installation done...
";;
    [4] ) yay -S 8188eu-dkms; echo "
Installation done...
";;
    [5] ) yay -S 8192cu-dkms; echo "
Installation done...
";;
  esac
done

while true; do
  echo "


For details, read:
https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#Correctly_detect_microphone_plugged_in_a_4-pin_3.5mm_(TRRS)_jack

"
  read -p "Detect microphone plugged in a 4-pin 3.5mm (TRRS) jack [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        echo "
Devices:
"
        aplay --list-devices
        read -p "


Check your HD Audio model here:
https://dri.freedesktop.org/docs/drm/sound/hd-audio/models.html or
http://git.alsa-project.org/?p=alsa-kernel.git;a=blob;f=Documentation/sound/alsa/HD-Audio-Models.txt;hb=HEAD

Enter HD Audio Model (e.g. mbp101, macbook-pro, laptop-dmic etc) or [e]xit:   " hdam
        case $hdam in
          [Ee] ) break 2;;
          * )
            sudo touch /etc/modprobe.d/alsa-base.conf;
            echo "
options snd_hda_intel index=0
options snd_hda_intel model=$hdam" | sudo tee /etc/modprobe.d/alsa-base.conf
            break;;
        esac
      done;;
  esac
done

echo '

####################################
####################################
###                              ###
###    INSTALLATION COMPLETE     ###
###    BETTER INSTALL DISPLAY    ###
###    SERVERS NOW ...           ###
###                              ###
####################################
####################################

'
