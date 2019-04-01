
#!/bin/bash

isHiDPI=false
dpi=DPI_VALUE
owner=$(whoami)
dir="$HOME/.theme-settings"
os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))

gen_conky_conf() {
  bash $HOME/.config/conky/generate-conky-config.sh $1
  bash $HOME/.config/conky/generate-conky-helper.sh $2
}

cp_settings() {
  cp "$HOME/Pictures/wallpapers/$2" "$HOME/Pictures/wallpapers/wallpaper.jpg"
  cp "$dir/$1/gtkrc-2.0" "$HOME/.gtkrc-2.0"
  cp "$dir/$1/gtkrc-3.0" "$HOME/.config/gtk-3.0/settings.ini"
  cp "$dir/$1/vscode-settings.json" "$HOME/.config/Code/User/settings.json"
  cp "$dir/$1/vscode-settings.json" "$HOME/.config/Code - OSS/User/settings.json"
  cp "$dir/$1/Xresources" "$HOME/.Xresources"

  if [ -f "/usr/share/backgrounds/grayscaled/grayscaled-$2" ];then
    sudo sed -i "s/background =.*/background = \/usr\/share\/backgrounds\/grayscaled\/grayscaled-$2/g" "/etc/lightdm/lightdm-gtk-greeter.conf"
  else
    sudo sed -i "s/background =.*/background = \/usr\/share\/backgrounds\/wallpapers\/$2/g" "/etc/lightdm/lightdm-gtk-greeter.conf"
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
    sed -i "s/^ascii_distro=.*/ascii_distro=auto/g" "$f"
    sed -i "s/^colors=.*/colors=$1/g" "$f"

    case $f in
      *"fedora"*|*"ubuntu"* )
        # dual color
        sed -i "s/^ascii_colors=.*/ascii_colors=$2/g" "$f";;
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
[c]  Lara Croft        [h]  Linux Distro
[d]  Nier              [i]  Dark Souls
[e]  Paint Splatter

Enter theme:   " category
  case $category in
    a )
      while true; do
        read -p "What theme to use?
[a]  Cleric Beast

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=1; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    b )
      while true; do
        read -p "What theme to use?
[a]  Aloy by hage_2013

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=2; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    c ) themeID=3; break;;
    d )
      while true; do
        read -p "What theme to use?
[a]  2B's sword
[b]  2B by 23i2ko
[c]  A2 by hage_2013

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
[a]  Pale Blue by BrandonMeier

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=8; break 2;;
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
[a]  Abyss Watcher

Enter theme:   " subcategory
        case $subcategory in
          a ) themeID=17; break 2;;
          * ) echo "Invalid input";;
        esac
      done;;
    * ) echo "Invalid input";;
  esac
done

case $themeID in
  1 )
    gen_conky_conf "#ffffff" "#ffffff"
    cp_settings "Bloodborne-Cleric-Beast" "bloodborne-cleric-beast.jpg" "#362130"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

    reload_i3;;
  2 )
    gen_conky_conf "#661a24" "#ffffff"
    cp_settings "Horizon-Zero-Dawn-Aloy-by-hage_2013" "horizon-zero-dawn-aloy-by-hage_2013.jpg" "#5f242a"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
  3 )
    gen_conky_conf "#ad6334" "#ad6334"
    cp_settings "Lara-Croft" "lara-croft.jpg" "#281d2e"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

    reload_i3;;
  4 )
    gen_conky_conf "#ffffff" "#ffffff"
    cp_settings "Nier-Sword" "nier-sword.jpg" "#1e1e21"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

    reload_i3;;
  5 )
    gen_conky_conf "#e44742" "#e44742"
    cp_settings "Nier-2B-by-23i2ko" "nier-2b-by-23i2ko.jpg" "#1e1e21"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(8 8 7 8 8 7)" "(8 7 8 8 8 8)" "(8 8 8 8 8 8)"

    reload_i3;;
  6 )
    gen_conky_conf "#070705" "#070705"
    cp_settings "Nier-A2-by-hage_2013" "nier-a2-by-hage_2013.jpg" "#070705"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
  7 )
    gen_conky_conf "#060d29" "#ffffff"
    cp_settings "Paint-Splatter" "paint-splatter.jpg" "#9c7a3"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
  8 )
    gen_conky_conf "#acbed4" "#acbed4"
    cp_settings "TLOU-Pale-Blue-by-BrandonMeier" "the-last-of-us-pale-blue-by-BrandonMeier.jpg" "#374d5b"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
  9 )
    gen_conky_conf "#2b343b" "#2b343b"
    cp_settings "Dark-Deer" "dark-deer.jpg" "#2b343b"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
  10 )
    use_solarized "linux-solarized-wallpaper-root.jpg";;
  11 )
    use_solarized "linux-solarized-wallpaper-arch.jpg";;
  12 )
    use_solarized "linux-solarized-wallpaper-fedora.jpg";;
  13 )
    use_solarized "linux-solarized-wallpaper-kali.jpg";;
  14 )
    use_solarized "linux-solarized-wallpaper-debian.jpg";;
  15 )
    use_solarized "linux-solarized-wallpaper-manjaro.jpg";;
  16 )
    use_solarized "linux-solarized-wallpaper-ubuntu.jpg";;
  17 )
    gen_conky_conf "#4a0e0e" "#4a0e0e"
    cp_settings "DS-Abyss-Watcher-by-nahamut" "dark-souls-abyss-watcher-low-poly-by-nahamut.jpg" "#ae9996"

    set_git_branch_colors "green bold" "yellow bold" "blue bold"
    set_git_diff_colors "blue bold" "blue bold" "red bold" "green bold"
    set_git_status_colors "green bold" "yellow bold" "red bold"
    set_neofetch_colors "(14 14 7 14 14 7)" "(14 7 14 14 14 14)" "(14 14 14 14 14 14)"

    reload_i3;;
esac


