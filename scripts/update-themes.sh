
#!/bin/bash

rm -rf $HOME/.theme-settings
rm -rf $HOME/.themes

# install themes
mkdir -p $HOME/.theme-settings
mkdir -p $HOME/.themes

usingDPI=false
dpiValue=96
while true; do
  xdpyinfo | grep -B 2 resolution
  read -p "

NOTE: This will generate HiDPI assets for GTK2.
Use HiDPI [yN]?   " uhdpi
  case $uhdpi in
    [Yy]* )
      while true; do
        xdpyinfo | grep -B 2 resolution
        read -p "Enter DPI or [e]xit   " dpi
        case $dpi in
          [Ee]* )
            break 2;;
          * )
            usingDPI=true
            dpiValue=$dpi
            break 2;;
        esac
      done;;
    * ) break;;
  esac
done

tsetting=materia
# temprarily disabled since i dont use qt apps that much making
# numix useless
# while true; do
# read -p "
#
# NOTE: If you use QT-based applications, use the numix variant instead
#
# What theme setting to use [default: 1] ?
# [1] Materia
# [2] Numix
# " ts
#   case $ts in
#     [1] ) tsetting=materia; break;;
#     [2] ) tsetting=numix;   break;;
#     * ) tsetting=materia; break;;
#   esac
# done

mkdir -p $HOME/Pictures/wallpapers
rm -rf $HOME/Pictures/wallpapers/*
cp -rf $(pwd)/rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

sudo mkdir -p /usr/share/backgrounds/wallpapers
sudo mkdir -p /usr/share/backgrounds/grayscaled
sudo rm -rf /usr/share/backgrounds/wallpapers/*
sudo rm -rf  /usr/share/backgrounds/grayscaled/*

sudo cp -rf $(pwd)/rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
sudo cp -rf $(pwd)/rice/images/wallpapers/grayscaled/* /usr/share/backgrounds/grayscaled

if [ -d $(pwd)/rice/images/wallpapers/private ]; then
  cp -rf $(pwd)/rice/images/wallpapers/private/compressed/*      $HOME/Pictures/wallpapers
  sudo cp -rf $(pwd)/rice/images/wallpapers/private/compressed/* /usr/share/backgrounds/wallpapers
  sudo cp -rf $(pwd)/rice/images/wallpapers/private/grayscaled/* /usr/share/backgrounds/grayscaled
fi

mkdir -p $HOME/.config/vifm/colors
cp -raf $(pwd)/rice/default.vifm   $HOME/.config/vifm/colors/Default.vifm

cp -raf $(pwd)/scripts/change-theme.sh   $HOME/.config/themes/change-theme.sh

if [ "$usingDPI" = true ];then
  sed -i "s/isHiDPI=false/isHiDPI=true/g" $HOME/.config/themes/change-theme.sh
  sed -i "s/dpi=DPI_VALUE/dpi=$dpiValue/g" $HOME/.config/themes/change-theme.sh
  tsetting+='-hidpi'
fi

themes=$(ls $(pwd)/themes)
for t in $themes; do
  if [ -d "$(pwd)/themes/$t" ] && [ "$t" != "Greeter" ]; then
    mkdir -p "$HOME/.theme-settings/$t/theme"
    mkdir -p "$HOME/.themes/$t"
    cp -raf "$(pwd)/themes/$t/."                          "$HOME/.theme-settings/$t"
    cp -raf "$HOME/.theme-settings/$t/theme/$tsetting/."  "$HOME/.themes/$t"
    rm -rf "$HOME/.theme-settings/$t/theme"
  fi
done

sudo mkdir -p /usr/share/themes/Greeter
sudo cp -raf $(pwd)/themes/Greeter/theme/$tsetting/*  /usr/share/themes/Greeter

if [ -f /usr/sbin/restorecon ]; then
  sudo restorecon -prF /usr/share/themes
fi

bash $HOME/.config/themes/change-theme.sh
