
#!/bin/bash

isHiDPI=false
dpi=DPI_VALUE
owner=$(whoami)
dir="$HOME/.theme-settings"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//"))

if [ "$os" == "pop" ]; then
  os="pop-os"
fi


gen_conky_conf() {
  bash $HOME/.config/conky/generate-conky-config.sh $1
  bash $HOME/.config/conky/generate-conky-helper.sh $2
}

cp_settings() {
  cp "$dir/$1/gtkrc-2.0" "$HOME/.gtkrc-2.0"
  cp "$dir/$1/gtkrc-3.0" "$HOME/.config/gtk-3.0/settings.ini"
  cp "$dir/$1/vscode-settings.json" "$HOME/.config/Code/User/settings.json"
  cp "$dir/$1/vscode-settings.json" "$HOME/.config/Code - OSS/User/settings.json"
  cp "$dir/$1/Xresources" "$HOME/.Xresources"

  if [ -f "$HOME/Pictures/wallpapers/$2" ]; then
    cp "$HOME/Pictures/wallpapers/$2" "$HOME/Pictures/wallpapers/wallpaper.jpg"
  else
    cp "$HOME/Pictures/wallpapers/404-wallpaper-not-found.jpg" "$HOME/Pictures/wallpapers/wallpaper.jpg"
  fi

  if [ -f "/usr/share/backgrounds/grayscaled/grayscaled-$2" ];then
    sudo sed -i "s/background =.*/background = \/usr\/share\/backgrounds\/grayscaled\/grayscaled-$2/g" "/etc/lightdm/lightdm-gtk-greeter.conf"
  else
    sudo sed -i "s/background =.*/background = \/usr\/share\/backgrounds\/wallpapers\/grayscaled-404-wallpaper-not-found.jpg/g" "/etc/lightdm/lightdm-gtk-greeter.conf"
  fi

  # sudo sed -i "s/background=.*/background=\/usr\/share\/backgrounds\/wallpapers\/$2/g" "/etc/lightdm/slick-greeter.conf"
  # sudo sed -i "s/background-color=.*/background-color=$3/g" "/etc/lightdm/slick-greeter.conf"

  if [ "$isHiDPI" = true ]; then
    sudo sed -i "s/! Xft/Xft/g" $HOME/.Xresources
    sudo sed -i "s/Xft.dpi:.*/Xft.dpi: $dpi/g" $HOME/.Xresources
  fi

  xrdb $HOME/.Xresources
}

set_git_branch_colors() {
    sed -i "s/current = .*/current = $1/g" "$HOME/.gitconfig"
    sed -i "s/local = .*/local = $2/g" "$HOME/.gitconfig"
    sed -i "s/remote = .*/remote = $3/g" "$HOME/.gitconfig"
}

set_git_diff_colors() {
    sed -i "s/meta = .*/meta = $1/g" "$HOME/.gitconfig"
    sed -i "s/frag = .*/frag = $2/g" "$HOME/.gitconfig"
    sed -i "s/old = .*/old = $3/g" "$HOME/.gitconfig"
    sed -i "s/new = .*/new = $4/g" "$HOME/.gitconfig"
}

set_git_status_colors() {
    sed -i "s/added = .*/added = $1/g" "$HOME/.gitconfig"
    sed -i "s/changed = .*/changed = $2/g" "$HOME/.gitconfig"
    sed -i "s/untracked = .*/untracked = $3/g" "$HOME/.gitconfig"
}

set_neofetch_colors() {
  if [ ! -f "$HOME/.config/neofetch/config.conf" ];then
    cp -rf "$HOME/.config/neofetch/config.conf" "$HOME/.config/neofetch/$os.conf"
  fi

  files=$(ls $HOME/.config/neofetch/*)
  for f in $files; do
    sed -i "s/^colors=.*/colors=$1/g" "$f"

    case $f in
      *"fedora"*|*"ubuntu"*|*"opensuse"*|*"gentoo"*|*"pop-os"* )
        # dual color
        sed -i "s/^ascii_colors=.*/ascii_colors=$2/g" "$f"
        cp -rf "$HOME/.config/neofetch/$os.conf" "$HOME/.config/neofetch/config.conf"
        ;;
      * )
        # single color
        sed -i "s/^ascii_colors=.*/ascii_colors=$3/g" "$f";;
    esac
  done
}

set_i3_colors() {
  sed -i "s/background #.*/background $1/g" "$HOME/.config/i3/config"
  sed -i "s/separator  #.*/separator  $2/g" "$HOME/.config/i3/config"
  sed -i "s/statusline #.*/statusline $3/g" "$HOME/.config/i3/config"

  sed -i "s/focused_workspace  #.*/focused_workspace  $1           $1            $3/g" "$HOME/.config/i3/config"
  sed -i "s/active_workspace   #.*/active_workspace   $1           $1            $3/g" "$HOME/.config/i3/config"
  sed -i "s/inactive_workspace #.*/inactive_workspace $1           $1            $2/g" "$HOME/.config/i3/config"
  sed -i "s/urgent_workspace   #.*/urgent_workspace   $1           $1            $4/g" "$HOME/.config/i3/config"

  sed -i "s/color_bad = .*/color_bad = '$4'/g" "$HOME/.config/i3/i3status.conf"
}

reload_i3() {
  i3-msg reload
  i3-msg restart
}

use_solarized() {
  gen_conky_conf "#2d8bcb" "#2d8bcb"
  cp_settings "Solarized" "$1" "#2d8bcb"

  set_git_branch_colors "green bold" "yellow bold" "blue bold"
  set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
  set_git_status_colors "green bold" "yellow bold" "red bold"
  set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

  reload_i3
}

themeID=1
while true; do
  read -p "What theme to use?
[a]  Bloodborne        [f]  TLOU
[b]  Horizon Zero Dawn [g]  Deer
[c]  Tomb Raider       [h]  Linux Distro
[d]  Nier              [i]  Dark Souls
[e]  Paint             [j]  Hollow Knight

Enter theme:   " category
  case $category in
    a )
      while true; do
        read -p "What theme to use?
[a]  Cleric Beast (Purple)
[b]  Eileen Minimal (Black/Gold)

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=1; break 2;;
          b ) themeID=19; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    b ) themeID=2; break;;
    c ) themeID=3; break;;
    d )
      while true; do
        read -p "What theme to use?
[a]  2B's sword (Dark Blue)
[b]  2B (Black/Orange)
[c]  A2 (Beige/Black)

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=4; break 2;;
          b ) themeID=5; break 2;;
          c ) themeID=6; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    e ) themeID=7; break;;
    f )
      while true; do
        read -p "What theme to use?
[a]  Pale Blue
[b]  Dark Green

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=8; break 2;;
          b ) themeID=22; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    g ) themeID=9; break;;
    h )
      while true; do
        read -p "What theme to use?
[a]  Solarized Root
[b]  Solarized Arch
[c]  Solarized Fedora
[d]  Solarized Kali
[e]  Solarized Debian
[f]  Solarized Manjaro
[g]  Solarized Ubuntu

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=10; break 2;;
          b ) themeID=11; break 2;;
          c ) themeID=12; break 2;;
          d ) themeID=13; break 2;;
          e ) themeID=14; break 2;;
          f ) themeID=15; break 2;;
          g ) themeID=16; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    i )
      while true; do
        read -p "What theme to use?
[a]  Abyss Watcher (Red/Grey)
[b]  Astorias (Blue/Grey)

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=17; break 2;;
          b ) themeID=18; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    j )
      while true; do
        read -p "What theme to use?
[a]  Grubfly (Dark Green)
[b]  Grimm (Pale Maroon)
[c]  Grimm 3 (Pale Purple)

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=20; break 2;;
          b ) themeID=21; break 2;;
          c ) themeID=23; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    * ) echo "Invalid input";;
  esac
done

case $themeID in
  1 )
    if [ -d "$dir/BB-Purple" ]; then
      gen_conky_conf "#ffffff" "#ffffff"
      cp_settings "BB-Purple" "bloodborne-cleric-beast-by-gelsgels.jpg" "#362130"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(15 15 15 15 8 7)" "(15 7 15 15 15 15)" "(15 15 15 15 15 15)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  2 )
    if [ -d "$dir/HZD-Red" ]; then
      gen_conky_conf "#661a24" "#ffffff"
      cp_settings "HZD-Red" "horizon-zero-dawn-aloy-by-hage_2013.jpg" "#5f242a"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  3 )
    if [ -d "$dir/TR-Purple-Orange" ]; then
      gen_conky_conf "#ad6334" "#ad6334"
      cp_settings "TR-Purple-Orange" "lara-croft.jpg" "#281d2e"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  4 )
    if [ -d "$dir/N-Dark-Blue" ]; then
      gen_conky_conf "#ffffff" "#ffffff"
      cp_settings "N-Dark-Blue" "nier-sword.jpg" "#1e1e21"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(12 12 7 12 12 7)" "(12 7 12 12 12 12)" "(12 12 12 12 12 12)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  5 )
    if [ -d "$dir/N-Black-Orange" ]; then
      gen_conky_conf "#e44742" "#e44742"
      cp_settings "N-Black-Orange" "nier-2b-by-23i2ko.jpg" "#1e1e21"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  6 )
    if [ -d "$dir/N-Beige-Black" ]; then
      gen_conky_conf "#070705" "#070705"
      cp_settings "N-Beige-Black" "nier-a2-by-hage_2013.jpg" "#070705"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  7 )
    if [ -d "$dir/P-Beige-Blue" ]; then
      gen_conky_conf "#060d29" "#ffffff"
      cp_settings "P-Beige-Blue" "paint-splatter.jpg" "#9c7a3"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  8 )
    if [ -d "$dir/TLOU-Pale-Blue" ]; then
      gen_conky_conf "#acbed4" "#acbed4"
      cp_settings "TLOU-Pale-Blue" "the-last-of-us-pale-blue-by-BrandonMeier.jpg" "#374d5b"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(15 15 7 15 15 7)" "(15 7 15 15 15 15)" "(15 15 15 15 15 15)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  9 )
    if [ -d "$dir/D-Red-Black" ]; then
      gen_conky_conf "#2b343b" "#2b343b"
      cp_settings "D-Red-Black" "dark-deer.jpg" "#2b343b"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  10 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-root.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  11 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-arch.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  12 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-fedora.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  13 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-kali.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  14 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-debian.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  15 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-manjaro.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  16 )
    if [ -d "$dir/Solarized" ]; then
      use_solarized "linux-solarized-wallpaper-ubuntu.jpg"
    else
      echo "Theme not found."
    fi
    ;;
  17 )
    if [ -d "$dir/DS-Red-Grey" ]; then
      gen_conky_conf "#4a0e0e" "#4a0e0e"
      cp_settings "DS-Red-Grey" "dark-souls-abyss-watcher-low-poly-by-nahamut.jpg" "#ae9996"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  18 )
    if [ -d "$dir/DS-Blue-Grey" ]; then
      gen_conky_conf "#284d81" "#284d81"
      cp_settings "DS-Blue-Grey" "dark-souls-astorias-low-poly-by-nahamut.jpg" "#284d81"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  19 )
    if [ -d "$dir/BB-Black-Gold" ]; then
      gen_conky_conf "#A39065" "#A39065"
      cp_settings "BB-Black-Gold" "bloodborne-eileen-minimal-by-dastardlyapparel.jpg" "#191919"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  20 )
    if [ -d "$dir/HK-Dark-Green" ]; then
      gen_conky_conf "#dbead3" "#dbead3"
      cp_settings "HK-Dark-Green" "hollow-knight-grubfly-by-drglovegood.jpg" "#495b4d"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  21 )
    if [ -d "$dir/HK-Pale-Maroon" ]; then
      gen_conky_conf "#181818" "#181818"
      cp_settings "HK-Pale-Maroon" "hollow-knight-grimm-by-drglovegood.jpg" "#624e57"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(15 15 7 15 15 7)" "(15 7 15 15 15 15)" "(15 15 15 15 15 15)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  22 )
    if [ -d "$dir/TLOU-Dark-Green" ]; then
      gen_conky_conf "#9f864d" "#9f864d"
      cp_settings "TLOU-Dark-Green" "the-last-of-us-dark-green-by-BrandonMeier.jpg" "#203731"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(15 15 7 15 15 7)" "(15 7 15 15 15 15)" "(15 15 15 15 15 15)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
  23 )
    if [ -d "$dir/HK-Pale-Purple" ]; then
      gen_conky_conf "#ebdbdc" "#ebdbdc"
      cp_settings "HK-Pale-Purple" "hollow-knight-grimmchild-3-by-drglovegood.jpg" "#2b282f"

      set_git_branch_colors "green bold" "yellow bold" "blue bold"
      set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
      set_git_status_colors "green bold" "yellow bold" "red bold"
      set_neofetch_colors "(15 15 7 15 15 7)" "(15 7 15 15 15 15)" "(15 15 15 15 15 15)"

      reload_i3
    else
      echo "Theme not found."
    fi
    ;;
esac


