
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"

uitheme=false
while true; do
  read -p "
NOTE: The custom icon themes takes some space and may take time to copy.
Use custom icon themes [yN]?   " uhdpi
  case $uhdpi in
    [Yy]* ) uitheme=true; break;;
    * ) uitheme=false; break;;
  esac
done

rm --verbose -rf $HOME/.theme-settings
rm --verbose -rf $HOME/.themes
rm --verbose -rf $HOME/.icons

# install themes
mkdir -p $HOME/.theme-settings
mkdir -p $HOME/.themes
mkdir -p $HOME/.icons

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

echo "Copying themes please wait..."

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
#
# Theme:   " ts
#   case $ts in
#     [1] ) tsetting=materia; break;;
#     [2] ) tsetting=numix;   break;;
#     * ) tsetting=materia; break;;
#   esac
# done

isetting=papirus
# temprarily disabled
# while true; do
# read -p "
#
# What icon theme to use [default: 1] ?
# [1] Papirus
# 
# Icon theme:   " its
#   case $its in
#     [1] ) isetting=papirus; break;;
#     * ) isetting=papirus; break;;
#   esac
# done

mkdir -p $HOME/Pictures/wallpapers
rm --verbose -rf $HOME/Pictures/wallpapers/*
cp --verbose -rf $DIR/../rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

sudo mkdir -p /usr/share/backgrounds/wallpapers
sudo mkdir -p /usr/share/backgrounds/grayscaled
sudo rm --verbose -rf /usr/share/backgrounds/wallpapers/*
sudo rm --verbose -rf  /usr/share/backgrounds/grayscaled/*

sudo cp --verbose -rf $DIR/../rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
sudo cp --verbose -rf $DIR/../rice/images/wallpapers/grayscaled/* /usr/share/backgrounds/grayscaled

if [ -d $DIR/../rice/images/wallpapers/private ]; then
  cp --verbose -rf $DIR/../rice/images/wallpapers/private/compressed/*      $HOME/Pictures/wallpapers
  sudo cp --verbose -rf $DIR/../rice/images/wallpapers/private/compressed/* /usr/share/backgrounds/wallpapers
  sudo cp --verbose -rf $DIR/../rice/images/wallpapers/private/grayscaled/* /usr/share/backgrounds/grayscaled
fi

mkdir -p $HOME/.config/vifm/colors
cp --verbose -raf $DIR/../rice/default.vifm   $HOME/.config/vifm/colors/Default.vifm

cp --verbose -raf $DIR/../user-scripts/change-theme.sh   $HOME/.config/themes/change-theme.sh

if [ "$usingDPI" = true ];then
  sed -i "s/isHiDPI=false/isHiDPI=true/g" $HOME/.config/themes/change-theme.sh
  sed -i "s/dpi=DPI_VALUE/dpi=$dpiValue/g" $HOME/.config/themes/change-theme.sh
  tsetting+='-hidpi'
fi

themes=$(ls $DIR/../themes)
for t in $themes; do
  if [ -d "$DIR/../themes/$t" ] && [ "$t" != "Greeter" ]; then
    mkdir -p "$HOME/.theme-settings/$t/theme"
    mkdir -p "$HOME/.themes/$t"

    cp --verbose -raf "$DIR/../themes/$t/."                         "$HOME/.theme-settings/$t"
    cp --verbose -raf "$HOME/.theme-settings/$t/theme/$tsetting/."  "$HOME/.themes/$t"

    if [ "$uitheme" = true ]; then
      mkdir -p "$HOME/.icons/$t"
      cp --verbose -raf "$DIR/../icon-themes/$t/$isetting/."  "$HOME/.icons/$t"
    else
      find $HOME/.theme-settings -type f | xargs sed -i "s/gtk-icon-theme-name=\".*/gtk-icon-theme-name=\"Papirus\"/g";
      find $HOME/.theme-settings -type f | xargs sed -i "s/gtk-icon-theme-name=[A-Za-z].*/gtk-icon-theme-name=Papirus/g";
    fi

    rm --verbose -rf "$HOME/.theme-settings/$t/theme"
  fi
done

while true; do
  read -p "Enable terminal blur (May slowdown terminal launch) [yN]?   " etb
  case $etb in
    [Yy]* ) find $HOME/.theme-settings -type f | xargs sed -i 's/!URxvt\*\.blurRadius/URxvt*.blurRadius/g'; break;;
    * ) break;;
  esac
done

sudo mkdir -p /usr/share/themes/Greeter
sudo cp --verbose -raf $DIR/../themes/Greeter/theme/$tsetting/*  /usr/share/themes/Greeter

if [ -f /usr/sbin/restorecon ]; then
  sudo restorecon -prF /usr/share/themes
fi

bash $HOME/.config/themes/change-theme.sh
