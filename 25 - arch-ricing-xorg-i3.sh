
#!/bin/bash

# Install display manager
yes | sudo pacman -S lightdm
yes | yay -S lightdm-settings
yes | yay -S noto-fonts
yes | yay -S lightdm-slick-greeter
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-slick-greeter/g' /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm

# Install window tiling manager
yes | sudo pacman -S dmenu i3-wm i3status i3lock rxvt-unicode

# File manager
yes | sudo pacman -S nautilus
# yes | sudo pacman -S pcmanfm-gtk3

if [ ! -f "$HOME/.riced" ];then
  mkdir -p $HOME/.config
  mkdir -p $HOME/.config/i3

  # Fix default i3 config
  sudo cp /etc/i3/config $HOME/.config/i3/config
  sudo chown $(whoami):wheel $HOME/.config/i3/config

  sed -i 's/Mod1/Mod4/g' $HOME/.config/i3/config
  sed -i 's/i3-sensible-terminal/urxvt/g' $HOME/.config/i3/config
  sed -i 's/dmenu_run/dmenu/g' $HOME/.config/i3/config

  sudo sed -i 's/Mod1/Mod4/g' /etc/i3/config
  sudo sed -i 's/i3-sensible-terminal/urxvt/g' /etc/i3/config
  sudo sed -i 's/dmenu_run/dmenu/g' /etc/i3/config

  # Fix default xinitrc config
  # cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
  # sudo chown $(whoami):wheel $HOME/.xinitrc

  # sed -i 's/twm&/ /g' $HOME/.xinitrc
  # sed -i 's/xclock -geometry 50x50-1+1 &/ /g' $HOME/.xinitrc
  # sed -i 's/xterm -geometry 80x50+494+51 &/ /g' $HOME/.xinitrc
  # sed -i 's/xterm -geometry 80x20+494-0 &/ /g' $HOME/.xinitrc
  # sed -i 's/exec xterm -geometry 80x66+0+0/exec i3/g' $HOME/.xinitrc

  # sudo sed -i 's/twm&/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xclock -geometry 50x50-1+1 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xterm -geometry 80x50+494+51 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/xterm -geometry 80x20+494-0 &/ /g' /etc/X11/xinit/xinitrc
  # sudo sed -i 's/exec xterm -geometry 80x66+0+0/ /g' /etc/X11/xinit/xinitrc

  cp -raf $(pwd)/rice/xinitrc $HOME/.xinitrc

  echo '
*.foreground:   #c5c8c6
*.background:   #1d1f21
*.cursorColor:  #c5c8c6
*.color0:       #282a2e
*.color8:       #373b41
*.color1:       #a54242
*.color9:       #cc6666
*.color2:       #8c9440
*.color10:      #b5bd68
*.color3:       #de935f
*.color11:      #f0c674
*.color4:       #5f819d
*.color12:      #81a2be
*.color5:       #85678f
*.color13:      #b294bb
*.color6:       #5e8d87
*.color14:      #8abeb7
*.color7:       #707880
*.color15:      #c5c8c6

  ' | tee $HOME/.Xresources

  sudo cp $HOME/.Xresources /root/.Xresources
fi

mainCWD=$(pwd)
while true; do
  read -p "

Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * ) 

      while true; do
        read -p "Will use for dual boot [yN]?   " wdb
        case $wdb in
          [Yy]* )
            while true; do
              echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other OS

"
              read -p "Enter UID or [e]xit:   " uid
              case $uid in
                [Ee]* ) break;;
                * )
                  while true; do
                    echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other OS

"
                    read -p "Enter GUID or [e]xit:   " guid
                    case $guid in
                      [Ee]* ) break 2;;
                      * )
                        while true; do
                          echo "

Execute the commands below in tty2 (Ctrl+Alt+F2) as a root user:

usermod -u $uid $(whoami)
groupmod -g $guid wheel

"
                          read -p "Would you like to proceed [Yn]?   " wultp
                          case $wultp in
                            [Nn]* ) ;;
                            * )
                              sudo usermod -g wheel $(whoami)
                              sudo chown -R $(whoami):wheel /home/$(whoami)
                              break 4;;
                          esac
                        done;;
                    esac
                  done;;
              esac
            done;;
          * ) break;;
        esac
      done

      # update all
      sudo pacman -Syu

      # theme icon
      yes | yay -S flat-remix-git
      yes | yay -S flat-remix-gtk-git

      # display
      yes | sudo pacman -S feh arandr lxappearance xorg-xbacklight xorg-xrandr

      # package manager - arch
      # yes | yay -S pamac-tray-appindicator pamac-aur --noconfirm

      # audio
      yes | sudo pacman -S alsa-utils 
      yes | sudo pacman -S pulseaudio pavucontrol --noconfirm
      yes | yay -S pa-applet-git

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      # network manager
      yes | sudo pacman -S networkmanager network-manager-applet
      sudo systemctl enable NetworkManager

      # fonts
      yes | sudo pacman -S noto-fonts
      # yes | yay -S nerd-fonts-complete
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

      sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
      sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
      sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"

      # terminal
      yes | sudo pacman -S neofetch

      # gtk theme change
      yes | sudo pacman -S gtk-engines gtk-engine-murrine gtk2 gtk3

      # mouse cursor theme, notification, system monitor, compositor, image on terminal
      yes | yay -S xcursor-breeze
      yes | sudo pacman -S dunst conky compton w3m

      # for vifm
      yes | sudo pacman -S ffmpegthumbnailer python-pip
      sudo pip3 install ueberzug

      # better desktop locker
      yes | yay -S i3lock-color-git

      # terminal-based file viewer
      yes | sudo pacman -S ranger vifm

      # requirements for ranger [scope.sh]
      yes | sudo pacman -S file libcaca pygmentize atool libarchive unrar lynx
      yes | sudo pacman -S mupdf-tools transmission-cli mediainfo odt2txt python-chardet

      # for ranger
      yes | yay -S rxvt-unicode-pixbuf

      # for polybar
      #
      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      #
      # r: repeat, z: shuffle, y: repeat one
      yes | sudo pacman -S mpd mpc ncmpcpp
      yes | sudo pacman -S libpulse jsoncpp libmpdclient

      # i3wm customization, dmenu replacement, i3status replacement
      yes | sudo pacman -S i3-gaps rofi
      yes | yay -S polybar --noconfirm

      # popup calendar
      # yay -S xdotool yad

      yes | yay -S scrot

      yes | sudo pacman -S accountsservice
      user=$(whoami)

      echo "
[User]
Icon=/var/lib/AccountsService/icons/$user.png
XSession=i3
SystemAccount=false
" | sudo tee /var/lib/AccountsService/users/$user

      sudo cp $(pwd)/rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
      sudo chown root:root /var/lib/AccountsService/users/$user
      sudo chown root:root /var/lib/AccountsService/icons/$user.png

      sudo chmod 644 /var/lib/AccountsService/users/$user
      sudo chmod 644 /var/lib/AccountsService/icons/$user.png

      if [ ! -f /usr/share/X11/xorg.conf.d/40-libinput.conf ];then
        sudo touch /usr/share/X11/xorg.conf.d/40-libinput.conf;
      fi

      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
      echo '
# Match on all types of devices but joysticks
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "NaturalScrolling" "true"
EndSection

Section "InputClass"
  Identifier "libinput keyboard catchall"
  MatchIsKeyboard "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"

  Option "Tapping" "true"
  Option "ScrollMethod" "twofinger"
  Option "NaturalScrolling" "true"
  Option "ClickMethod" "clickfinger"
  Option "TappingDrag" "true"
EndSection

Section "InputClass"
  Identifier "libinput touchscreen catchall"
  MatchIsTouchscreen "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection

Section "InputClass"
  Identifier "libinput tablet catchall"
  MatchIsTablet "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
EndSection
      ' | sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf

      if [ ! -f $HOME/.riced ]; then
        mkdir -p $HOME/.icons/default
        echo "
[Icon Theme]
Inherits=Breeze
        " | tee $HOME/.icons/default/index.theme

        while true; do
          read -p "Do you want to configure git [Yn]?   " yn
          case $yn in
            [Nn]* ) break;;
            * )
              while true; do
                read -p "Enter email or [e]xit:   " email
                case $email in
                  [Ee] ) break;;
                  * )
                    while true; do
                      read -p "Enter name or [e]xit:   " name
                      case $name in
                        [Ee] ) break 2;;
                        * )
                          while true; do
                            read -p "Enter username or [e]xit:   " username
                            case $username in
                              [Ee] ) break 3;;
                              * ) echo "
[user]
  email = $email
  name = $name
  username = $username
[diff]
  tool = vimdiff
[difftool]
  prompt = false
[color]
  ui = auto
[color \"branch\"]
  current = yellow reverse
  local = yellow
  remote = green
[color \"diff\"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold
[color \"status\"]
  added = yellow
  changed = green
  untracked = cyan
" | tee $HOME/.gitconfig;

                                break 4;;
                            esac
                          done;;
                      esac
                    done;;
                esac
              done;;
          esac
        done

        # create folders for executables
        mkdir -p $HOME/.config/audio
        mkdir -p $HOME/.config/display
        mkdir -p $HOME/.config/conky
        mkdir -p $HOME/.config/keyboard
        mkdir -p $HOME/.config/i3
        mkdir -p $HOME/.config/kali
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/network
        mkdir -p $HOME/.config/touchpad
        mkdir -p $HOME/.config/themes
        mkdir -p $HOME/.config/vifm
        mkdir -p $HOME/.config/vifm/scripts

        # create folders for configs
        mkdir -p  "$HOME/.config/Code"
        mkdir -p  "$HOME/.config/Code/User"
        mkdir -p  "$HOME/.config/Code - OSS"
        mkdir -p  "$HOME/.config/Code - OSS/User"
        mkdir -p  "$HOME/.config/gtk-3.0"

        # copy vscode user settings
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code/User/keybindings.json"
        cp $(pwd)/rice/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

        # copy executables
        cp $(pwd)/scripts/volume-manager.sh                   $HOME/.config/audio/volume-manager.sh
        cp $(pwd)/scripts/brightness-manager.sh               $HOME/.config/display/brightness-manager.sh
        cp $(pwd)/scripts/lockscreen.sh                       $HOME/.config/display/lockscreen.sh
        cp $(pwd)/scripts/generate-conky-config.sh            $HOME/.config/conky/generate-conky-config.sh
        cp $(pwd)/scripts/generate-conky-helper.sh            $HOME/.config/conky/generate-conky-helper.sh
        cp $(pwd)/scripts/keyboard-disabler.sh                $HOME/.config/keyboard/keyboard-disabler.sh
        cp $(pwd)/scripts/polybar.sh                          $HOME/.config/i3/polybar.sh
        cp $(pwd)/scripts/startup.sh                          $HOME/.config/i3/startup.sh
        cp $(pwd)/scripts/kali-rofi.sh                        $HOME/.config/kali/rofi.sh
        cp $(pwd)/scripts/kali-launch.sh                      $HOME/.config/kali/launch.sh
        cp $(pwd)/scripts/spawn-mpd.sh                        $HOME/.config/mpd/spawn-mpd.sh
        cp $(pwd)/scripts/network-connect.sh                  $HOME/.config/network/network-connect.sh
        cp $(pwd)/scripts/update-mirrors.sh                   $HOME/.config/network/update-mirrors.sh
        cp $(pwd)/scripts/toggle-touchpad.sh                  $HOME/.config/touchpad/toggle-touchpad.sh
        cp $(pwd)/scripts/popup-calendar.sh                   $HOME/.config/polybar/popup-calendar.sh
        cp $(pwd)/scripts/update-checker.sh                   $HOME/.config/polybar/update-checker.sh
        cp $(pwd)/scripts/change-theme.sh                     $HOME/.config/themes/change-theme.sh
        cp $(pwd)/scripts/update-polybar-network-interface.sh $HOME/.config/themes/update-polybar-network-interface.sh
        cp $(pwd)/scripts/vifm-run.sh                         $HOME/.config/vifm/scripts/vifm-run.sh
        cp $(pwd)/scripts/vifm-viewer.sh                      $HOME/.config/vifm/scripts/vifm-viewer.sh

        # copy keyboard-disabler icons
        # cp $(pwd)/rice/images/keyboard/* $HOME/.config/keyboard

        # make executables
        sudo chmod +x $HOME/.config/audio/volume-manager.sh
        sudo chmod +x $HOME/.config/display/brightness-manager.sh
        sudo chmod +x $HOME/.config/display/lockscreen.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-config.sh
        sudo chmod +x $HOME/.config/conky/generate-conky-helper.sh
        sudo chmod +x $HOME/.config/keyboard/keyboard-disabler.sh
        sudo chmod +x $HOME/.config/i3/polybar.sh
        sudo chmod +x $HOME/.config/i3/startup.sh
        sudo chmod +x $HOME/.config/kali/rofi.sh
        sudo chmod +x $HOME/.config/kali/launch.sh
        sudo chmod +x $HOME/.config/mpd/spawn-mpd.sh
        sudo chmod +x $HOME/.config/network/network-connect.sh
        sudo chmod +x $HOME/.config/network/update-mirrors.sh
        sudo chmod +x $HOME/.config/touchpad/toggle-touchpad.sh
        sudo chmod +x $HOME/.config/polybar/popup-calendar.sh
        sudo chmod +x $HOME/.config/polybar/update-checker.sh
        sudo chmod +x $HOME/.config/themes/change-theme.sh
        sudo chmod +x $HOME/.config/themes/update-polybar-network-interface.sh
        sudo chmod +x $HOME/.config/vifm/scripts/vifm-run.sh
        sudo chmod +x $HOME/.config/vifm/scripts/vifm-viewer.sh

        # create .bashrc if not exists
        if [ ! -f $HOME/.bashrc ]; then
          touch $HOME/.bashrc;
        fi

        echo "

# If not running interactively, don't do anythin
[[ \$- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\\\$ '

# Enable history appending instead of overwriting.
shopt -s histappend

# change theme alias
alias spawn-mpd='$HOME/.config/mpd/spawn-mpd.sh'
alias network-connect='$HOME/.config/network/network-connect.sh'
alias update-mirrors='$HOME/.config/network/update-mirrors.sh'
alias change-theme='$HOME/.config/themes/change-theme.sh'
alias vifm='$HOME/.config/vifm/scripts/vifm-run.sh'
alias update-polybar-network-interface='$HOME/.config/themes/update-polybar-network-interface.sh'

PATH=\"\$HOME/.local/bin:\$HOME/bin:\$PATH\"
export PATH;

# execute neofetch depending on cols and lines in .bashrc
os=\$(echo -n \$(cat /etc/*-release | grep ^ID= | sed -e \"s/ID=//\"))
cols=\$(tput cols)
lines=\$(tput lines)
if [ \"\$cols\" -gt 67 ] && [ \"\$lines\" -gt 34 ];
then
  neofetch --config \"$HOME/.config/neofetch/\$os.conf\"
fi

export EDITOR=vim

        " | tee $HOME/.bashrc

        # vifm
        cp -raf $(pwd)/rice/vifmrc  $HOME/.config/vifm/vifmrc

        # copy vim colors
        mkdir -p $HOME/.vim
        cp -raf $(pwd)/rice/.vim/*  $HOME/.vim
        cp -raf $(pwd)/rice/.vimrc  $HOME/.vimrc

        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

        # copy wallpapers
        mkdir -p $HOME/Pictures/wallpapers
        cp -rf $(pwd)/rice/images/wallpapers/compressed/* $HOME/Pictures/wallpapers

        # copy ranger configs
        mkdir -p $HOME/.config/ranger
        cp -rf $(pwd)/rice/ranger/* $HOME/.config/ranger

        # copy i3 config
        mkdir -p $HOME/.config/i3
        cp -rf $(pwd)/rice/config-i3      $HOME/.config/i3/config
        cp -rf $(pwd)/rice/i3status.conf  $HOME/.config/i3/i3status.conf

        sed -i 's/# exec --no-startup-id pa-applet/exec --no-startup-id pa-applet/g' $HOME/.config/i3/config

        # copy ncmpcpp config
        mkdir -p $HOME/.ncmpcpp
        cp -rf $(pwd)/rice/config-ncmpcpp $HOME/.ncmpcpp/config

        # copy polybar config
        mkdir -p $HOME/.config/polybar
        cp -rf $(pwd)/rice/config-polybar $HOME/.config/polybar/config
        bash $(pwd)/scripts/update-polybar-network-interface.sh

        # copy i3status config
        sudo cp -rf $(pwd)/rice/i3status.conf /etc/i3status.conf

        # copy mpd config
        mkdir -p $HOME/.config/mpd
        mkdir -p $HOME/.config/mpd/playlists
        cp -rf $(pwd)/rice/mpd.conf $HOME/.config/mpd/mpd.conf

        # copy neofetch config
        mkdir -p $HOME/.config/neofetch
        cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/config.conf

        # copy compton config
        mkdir -p $HOME/.config/compton
        cp -rf $(pwd)/rice/compton.conf $HOME/.config/compton/config.conf

        # copy dunst config
        mkdir -p $HOME/.config/dunst
        cp -rf $(pwd)/rice/dunstrc $HOME/.config/dunst/dunstrc

        while true; do
          read -p "Do you want to activate keyboard disabler [yN]?   " yn
          case $yn in
            [Yy]* )
              while true; do
                xinput
                read -p "

Enter device ID:   " did
                case $did in
                  * )
                    echo "exec --no-startup-id ~/.config/keyboard/keyboard-disabler.sh $did" | tee -a $HOME/.config/i3/config
                    break 2;;
                esac
              done;;
            * ) break;;
          esac
        done

        touch $HOME/.riced
      fi

      # NOTE: needs adjustment for the sake of fedora
      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

      cd $mainCWD

      # sed -i "s/# exec --no-startup-id pamac-tray/exec --no-startup-id pamac-tray/g" $HOME/.config/i3/config
      # sed -i "s/# for_window \[class=\"Pamac-manager\"\]/for_window [class=\"Pamac-manager\"]/g" $HOME/.config/i3/config

      os=$(echo -n $(sudo cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))
      mkdir -p "$HOME/.config/neofetch"
      cp -rf $(pwd)/rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      echo "
[Icon Theme]
Inherits=Breeze
      " | sudo tee /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo mkdir -p /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/images/wallpapers/compressed/* /usr/share/backgrounds/wallpapers
      sudo cp -rf $(pwd)/rice/slick-greeter.conf /etc/lightdm/slick-greeter.conf

      bash $(pwd)/scripts/update-screen-detector.sh
      bash $(pwd)/scripts/update-themes.sh
      yes | sudo pacman -Rns $(pacman -Qtdq)

      echo '

####################################
####################################
###                              ###
###    RICING COMPLETE...        ###
###                              ###
####################################
####################################

'

      break;;
  esac
done
