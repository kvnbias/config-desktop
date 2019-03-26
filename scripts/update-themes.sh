
#!/bin/bash

rm -rf $HOME/.theme-settings
rm -rf $HOME/.themes

# install themes
mkdir -p $HOME/.theme-settings
mkdir -p $HOME/.themes

mkdir -p $HOME/.theme-settings/Bloodborne/theme
mkdir -p $HOME/.theme-settings/Dark-Deer/theme
mkdir -p $HOME/.theme-settings/Default/theme
mkdir -p $HOME/.theme-settings/Horizon-Zero-Dawn/theme
mkdir -p $HOME/.theme-settings/Lara-Croft/theme
mkdir -p $HOME/.theme-settings/Nier-2B/theme
mkdir -p $HOME/.theme-settings/Paint-Splatter/theme
mkdir -p $HOME/.theme-settings/Solarized/theme
mkdir -p $HOME/.theme-settings/TLOU-Pale-Blue/theme

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
cp -rf $(pwd)/rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

sudo mkdir -p /usr/share/backgrounds/wallpapers
sudo mkdir -p /usr/share/backgrounds/grayscaled

sudo cp -rf $(pwd)/rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
sudo cp -rf $(pwd)/rice/images/wallpapers/grayscaled/* /usr/share/backgrounds/grayscale

cp -raf $(pwd)/scripts/change-theme.sh   $HOME/.config/themes/change-theme.sh

if [ "$usingDPI" = true ];then
  sed -i "s/isHiDPI=false/isHiDPI=true/g" $HOME/.config/themes/change-theme.sh
  sed -i "s/dpi=DPI_VALUE/dpi=$dpiValue/g" $HOME/.config/themes/change-theme.sh
  tsetting+='-hidpi'
fi

cp -raf $(pwd)/themes/Bloodborne/*                    $HOME/.theme-settings/Bloodborne
cp -raf $(pwd)/themes/Dark-Deer/*                     $HOME/.theme-settings/Dark-Deer
cp -raf $(pwd)/themes/Default/*                       $HOME/.theme-settings/Default
cp -raf $(pwd)/themes/Horizon-Zero-Dawn/*             $HOME/.theme-settings/Horizon-Zero-Dawn
cp -raf $(pwd)/themes/Lara-Croft/*                    $HOME/.theme-settings/Lara-Croft
cp -raf $(pwd)/themes/Nier-2B/*                       $HOME/.theme-settings/Nier-2B
cp -raf $(pwd)/themes/Paint-Splatter/*                $HOME/.theme-settings/Paint-Splatter
cp -raf $(pwd)/themes/Solarized/*                     $HOME/.theme-settings/Solarized
cp -raf $(pwd)/themes/TLOU-Pale-Blue/*                $HOME/.theme-settings/TLOU-Pale-Blue

mkdir -p $HOME/.themes/Bloodborne
mkdir -p $HOME/.themes/Dark-Deer
mkdir -p $HOME/.themes/Default
mkdir -p $HOME/.themes/Horizon-Zero-Dawn
mkdir -p $HOME/.themes/Lara-Croft
mkdir -p $HOME/.themes/Nier-2B
mkdir -p $HOME/.themes/Paint-Splatter
mkdir -p $HOME/.themes/Solarized
mkdir -p $HOME/.themes/TLOU-Pale-Blue

cp -raf $HOME/.theme-settings/Bloodborne/theme/$tsetting/*                     $HOME/.themes/Bloodborne
cp -raf $HOME/.theme-settings/Dark-Deer/theme/$tsetting/*                      $HOME/.themes/Dark-Deer
cp -raf $HOME/.theme-settings/Default/theme/$tsetting/*                        $HOME/.themes/Default
cp -raf $HOME/.theme-settings/Horizon-Zero-Dawn/theme/$tsetting/*              $HOME/.themes/Horizon-Zero-Dawn
cp -raf $HOME/.theme-settings/Lara-Croft/theme/$tsetting/*                     $HOME/.themes/Lara-Croft
cp -raf $HOME/.theme-settings/Nier-2B/theme/$tsetting/*                        $HOME/.themes/Nier-2B
cp -raf $HOME/.theme-settings/Paint-Splatter/theme/$tsetting/*                 $HOME/.themes/Paint-Splatter
cp -raf $HOME/.theme-settings/Solarized/theme/$tsetting/*                      $HOME/.themes/Solarized
cp -raf $HOME/.theme-settings/TLOU-Pale-Blue/theme/$tsetting/*                 $HOME/.themes/TLOU-Pale-Blue

sudo mkdir -p /usr/share/themes/Greeter
sudo cp -raf $(pwd)/themes/Greeter/theme/$tsetting/*  /usr/share/themes/Greeter

if [ -f /usr/sbin/restorecon ]; then
  sudo restorecon -prF /usr/share/themes
fi

bash $HOME/.config/themes/change-theme.sh
