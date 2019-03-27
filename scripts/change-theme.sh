
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
    sed -i "s/^ascii_distro=.*/ascii_distro=$1/g" "$f"
    sed -i "s/^colors=.*/colors=$2/g" "$f"
  done

  case $os in
    fedora|ubuntu )
      # dual color
      sed -i "s/^ascii_colors=.*/ascii_colors=$4/g" "$HOME/.config/neofetch/$os.conf";;
    * )
      # single color
      sed -i "s/^ascii_colors=.*/ascii_colors=$3/g" "$HOME/.config/neofetch/$os.conf";;
  esac
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

  if [ ! -f "$HOME/Pictures/wallpapers/solarized-wallpaper-$1.jpg" ]; then
    cp_settings "Linux-Solarized" "linux-solarized-wallpaper-root.jpg" "#2d8bcb"
  else
    cp_settings "Linux-Solarized" "linux-solarized-wallpaper-$1.jpg" "#2d8bcb"
  fi

  set_i3_colors "#2d8bcb" "#0d68a6" "#0e3642" "#0e3642"

  single='(10 10 10 10 10 10)';
  dual='(10 7 10 10 10 10)';

  set_git_branch_colors "black bold" "green bold" "red bold"
  set_git_diff_colors "yellow bold" "yellow bold" "red bold" "black bold"
  set_git_status_colors "black bold" "yellow bold" "red bold"
  set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

  reload_i3
}

while true; do
  read -p "What theme to use?
[a]  Bloodborne        [f]  TLOU
[b]  Horizon Zero Dawn [g]  Deer
[c]  Lara Croft        [h]  Solarized Root
[d]  2B                [i]  Solarized Arch
[e]  Paint Splatter    [j]  Solarized Fedora

[k]  Solarized Kali    [*]  Default
[l]  Solarized Debian
[m]  Solarized Manjaro
[n]  Solarized Ubuntu


Enter theme:   " theme
  case $theme in
    [a] )
      gen_conky_conf "#ffffff" "#ffffff"
      cp_settings "Bloodborne-Cleric-Beast" "bloodborne-cleric-beast.jpg" "#362130"
      set_i3_colors "#f2e5dc" "#a1894e" "#2d1b27" "#92082A"

      single='(1 1 1 1 1 1)';
      dual='(1 2 1 1 1 1)';

      set_git_branch_colors "blue bold" "cyan bold" "black bold"
      set_git_diff_colors "white bold" "cyan bold" "black bold" "blue bold"
      set_git_status_colors "blue bold" "black bold" "cyan bold"
      set_neofetch_colors "auto" "(1 1 10 9 9 10)" "$single" "$dual"

      reload_i3
      break;;
    [b] )
      gen_conky_conf "#661a24" "#ffffff"
      cp_settings "Horizon-Zero-Dawn-Aloy" "horizon-zero-dawn-aloy.jpg" "#5f242a"
      set_i3_colors "#fdeddd" "#6c837b" "#5f242a" "#92082A"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';
      
      set_git_branch_colors "white bold" "blue bold" "black bold"
      set_git_diff_colors "red bold" "green bold" "cyan bold" "white bold"
      set_git_status_colors "white bold" "black bold" "cyan bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [c] )
      gen_conky_conf "#ad6334" "#ad6334"
      cp_settings "Lara-Croft" "lara-croft.jpg" "#281d2e"
      set_i3_colors "#241b2e" "#ebf4f1" "#ad6334" "#ad6334"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';

      set_git_branch_colors "black bold" "red bold" "green bold"
      set_git_diff_colors "red bold" "yellow bold" "white bold" "black bold"
      set_git_status_colors "black bold" "green bold" "red bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [d] )
      gen_conky_conf "#e44742" "#e44742"
      cp_settings "Nier-2B" "nier-2b.jpg" "#1e1e21"
      set_i3_colors "#dad3cd" "#050a0e" "#e44742" "#e44742"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';

      set_git_branch_colors "yellow bold" "green bold" "black bold"
      set_git_diff_colors "black bold" "black bold" "green bold" "yellow bold"
      set_git_status_colors "yellow bold" "black bold" "green bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [e] )
      gen_conky_conf "#060d29" "#ffffff"
      cp_settings "Paint-Splatter" "paint-splatter.jpg" "#9c7a3"
      set_i3_colors "#D6C4A0" "#A89267" "#29253c" "#29253c"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';

      set_git_branch_colors "cyan bold" "white bold" "magenta bold"
      set_git_diff_colors "magenta bold" "magenta bold" "white bold" "cyan bold"
      set_git_status_colors "cyan bold" "magenta bold" "white bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [f] )
      gen_conky_conf "#acbed4" "#acbed4"
      cp_settings "TLOU-Pale-Blue" "the-last-of-us-pale-blue.jpg" "#374d5b"
      set_i3_colors "#c0c3c6" "#667c8b" "#374d5b" "#374d5b"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';

      set_git_branch_colors "red bold" "green bold" "yellow bold"
      set_git_diff_colors "blue bold" "blue bold" "yellow bold" "red bold"
      set_git_status_colors "red bold" "green bold" "yellow bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [g] )
      gen_conky_conf "#2b343b" "#2b343b"
      cp_settings "Dark-Deer" "dark-deer.jpg" "#2b343b"
      set_i3_colors "#C44741" "#9C3531" "#2B343B" "#2B343B"

      single='(10 10 10 10 10 10)';
      dual='(10 7 10 10 10 10)';

      set_git_branch_colors "black bold" "magenta bold" "white bold"
      set_git_diff_colors "magenta bold" "magenta bold" "green bold" "black bold"
      set_git_status_colors "black bold" "red bold" "green bold"
      set_neofetch_colors "auto" "(10 10 7 10 10 7)" "$single" "$dual"

      reload_i3
      break;;
    [h] )
      use_solarized "root"
      break;;
    [i] )
      use_solarized "arch"
      break;;
    [j] )
      use_solarized "fedora"
      break;;
    [k] )
      use_solarized "kali"
      break;;
    [l] )
      use_solarized "debian"
      break;;
    [m] )
      use_solarized "manjaro"
      break;;
    [n] )
      use_solarized "ubuntu"
      break;;
    * )
      gen_conky_conf "#ffffff" "#ffffff"
      cp_settings "Nier-Sword" "nier-sword.jpg" "#1e1e21"
      set_i3_colors "#111320" "#534e54" "#ffffff" "#ffffff"

      single='(12 12 12 12 12 12)';
      dual='(12 7 12 12 12 12)';

      set_git_branch_colors "green bold" "blue bold" "red bold"
      set_git_diff_colors "blue bold" "yellow bold" "red bold" "green bold"
      set_git_status_colors "green bold" "red bold" "yellow bold"
      set_neofetch_colors "auto" "(12 12 7 12 12 7)" "$single" "$dual"

      reload_i3
      break;;
  esac
done
