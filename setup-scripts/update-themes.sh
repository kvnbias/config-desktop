
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"

wallpapersDIR="$DIR/../rice/images/wallpapers"
themesDIR="$DIR/../themes"
iconsDIR="$DIR/../icon-themes"

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

if [ ! -d "$wallpapersDIR/compressed" ] && [ ! -d "$wallpapersDIR/grayscaled" ]; then
  while true; do
    read -p "
The wallpaper DIR is empty.

[1] Enter custom wallpaper directory (contains 'compressed' & 'grayscaled' dir)
[2] Skip

Action:   " wdira
    case $wdira in
      1 )
        while true; do
          read -p "Enter wallpaper directory:   " wdir
          case $wdir in
            * )
              if [ ! -d "$wdir/compressed" ] && [ ! -d "$wdir/grayscaled" ]; then
                echo "Directory is invalid."; break;
              else
                wallpapersDIR="$wdir"; break 2;
              fi
          esac
        done;;
      2 ) break;;
      * ) echo "Invalid action.";;
    esac
  done
fi

mkdir -p $HOME/Pictures/wallpapers
rm --verbose -rf $HOME/Pictures/wallpapers/*
cp --verbose -rf $wallpapersDIR/compressed/* $HOME/Pictures/wallpapers

sudo mkdir -p /usr/share/backgrounds/wallpapers
sudo mkdir -p /usr/share/backgrounds/grayscaled
sudo rm --verbose -rf /usr/share/backgrounds/wallpapers/*
sudo rm --verbose -rf  /usr/share/backgrounds/grayscaled/*

sudo cp --verbose -rf $wallpapersDIR/compressed/* /usr/share/backgrounds/wallpapers
sudo cp --verbose -rf $wallpapersDIR/grayscaled/* /usr/share/backgrounds/grayscaled

if [ -d $wallpapersDIR/private ]; then
  cp --verbose -rf $wallpapersDIR/private/compressed/*      $HOME/Pictures/wallpapers
  sudo cp --verbose -rf $wallpapersDIR/private/compressed/* /usr/share/backgrounds/wallpapers
  sudo cp --verbose -rf $wallpapersDIR/private/grayscaled/* /usr/share/backgrounds/grayscaled
fi

mkdir -p $HOME/.config/vifm/colors
cp --verbose -raf $DIR/../rice/default.vifm   $HOME/.config/vifm/colors/Default.vifm

cp --verbose -raf $DIR/../user-scripts/change-theme.sh   $HOME/.config/themes/change-theme.sh

if [ "$usingDPI" = true ];then
  sed -i "s/isHiDPI=false/isHiDPI=true/g" $HOME/.config/themes/change-theme.sh
  sed -i "s/dpi=DPI_VALUE/dpi=$dpiValue/g" $HOME/.config/themes/change-theme.sh
  tsetting+='-hidpi'
fi

if [ "$(ls -la $themesDIR | wc -l)" -lt 4 ]; then
  while true; do
    read -p "
The theme DIR is empty.

[1] Enter custom themes directory
[2] Skip

Action:   " ctdira
    case $ctdira in
      1 )
        while true; do
          read -p "Enter themes directory:   " tdir
          case $tdir in
            * )
              if [ "$(ls -la $tdir | wc -l)" -lt 4 ]; then
                echo "Directory is invalid."; break;
              else
                themesDIR="$tdir"; break 2;
              fi
          esac
        done;;
      2 ) break;;
      * ) echo "Invalid action.";;
    esac
  done
fi

themes=$(ls $themesDIR)
for t in $themes; do
  if [ -d "$themesDIR/$t" ] && [ "$t" != "Greeter" ]; then
    mkdir -p "$HOME/.theme-settings/$t/theme"
    mkdir -p "$HOME/.themes/$t"

    cp --verbose -raf "$themesDIR/$t/."                             "$HOME/.theme-settings/$t"
    cp --verbose -raf "$HOME/.theme-settings/$t/theme/$tsetting/."  "$HOME/.themes/$t"

    if [ "$uitheme" = true ]; then
      if [ "$(ls -la $iconsDIR | wc -l)" -lt 4 ]; then
        while true; do
          read -p "
The icons DIR is empty.

[1] Enter custom icons directory
[2] Skip

Action:   " cidira
          case $cidira in
            1 )
              while true; do
                read -p "Enter icons directory:   " idir
                case $idir in
                  * )
                    if [ "$(ls -la $idir | wc -l)" -lt 4 ]; then
                      echo "Directory is invalid."; break;
                    else
                      iconsDIR="$idir"; break 2;
                    fi
                esac
              done;;
            2 ) break;;
            * ) echo "Invalid action.";;
          esac
        done
      fi

      mkdir -p "$HOME/.icons/$t"
      cp --verbose -raf "$iconsDIR/$t/$isetting/."  "$HOME/.icons/$t"
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
sudo cp --verbose -raf $themesDIR/Greeter/theme/$tsetting/*  /usr/share/themes/Greeter

if [ -f /usr/sbin/restorecon ]; then
  sudo restorecon -prF /usr/share/themes
fi

bash $HOME/.config/themes/change-theme.sh
