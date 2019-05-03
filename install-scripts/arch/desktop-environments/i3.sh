
#!/bin/bash

# Install window tiling manager
yes | sudo pacman -S dmenu i3-wm i3status i3lock rxvt-unicode

if [ ! -f "$HOME/.riced" ];then
  cp -raf "$DIR/../../../rice/xinitrc"         "$HOME/.xinitrc"
  cp -raf "$DIR/../../../rice/base-i3-config"  "$HOME/.Xresources"
  cp -raf "$DIR/../../../rice/base-Xresources" "$HOME/.Xresources"
  sudo cp "$HOME/.Xresources"               "/root/.Xresources"
fi

while true; do
  read -p "Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * ) 
      yes | sudo pacman -S curl wget vim git gedit
      yes | sudo pacman -S papirus-icon-theme
      yes | sudo pacman -S feh arandr lxappearance-gtk3 xorg-xbacklight xorg-xrandr xorg-xrdb xorg-xinput

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      yes | sudo pacman -S alsa-utils 
      yes | sudo pacman -S pulseaudio pavucontrol --noconfirm
      yes | yay -S pa-applet-git

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      yes | sudo pacman -S networkmanager network-manager-applet
      sudo systemctl enable NetworkManager

      yes | sudo pacman -S noto-fonts
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
      wget https://github.com/ryanoasis/nerd-fonts/raw/v2.0.0/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

      sudo mkdir -p /usr/share/fonts/nerd-fonts-complete/ttf
      sudo mv "Ubuntu Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Nerd Font Complete Mono.ttf"       "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf"
      sudo mv "Roboto Mono Bold Nerd Font Complete Mono.ttf"  "/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf"
      sudo mv "Sauce Code Pro Nerd Font Complete Mono.ttf"    "/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf"

      yes | sudo pacman -S neofetch
      yes | sudo pacman -S gtk2 gtk3

      yes | yay -S xcursor-breeze
      yes | sudo pacman -S dunst conky compton w3m
      yes | sudo pacman -S ffmpegthumbnailer

      if [ ! -d /usr/share/icons/Breeze ]; then
        sudo ln -sf /usr/share/icons/xcursor-breeze /usr/share/icons/Breeze
      fi

      # https://pillow.readthedocs.io/en/stable/installation.html
      yes | sudo pacman -S python-pip
      sudo pip3 install ueberzug
      yes | sudo pacman -S poppler mediainfo transmission-cli
      yes | sudo pacman -S zip unzip tar xz unrar catdoc odt2txt docx2txt

      yes | sudo pacman -Rns i3lock
      yes 1 | yay -S i3lock-color --noconfirm

      yes | sudo pacman -S ranger vifm

      yes | sudo pacman -S file libcaca pygmentize atool libarchive unrar lynx
      yes | sudo pacman -S mupdf-tools transmission-cli mediainfo odt2txt python-chardet
      yes | yay -S rxvt-unicode-pixbuf

      # ncmpcpp playlist
      # 1) go to browse
      # 2) press "v" (it reverse selection, so when you have nothing selected, it selects all)
      # 3) press "A"
      # r: repeat, z: shuffle, y: repeat one
      yes | sudo pacman -S mpd mpc ncmpcpp
      yes | sudo pacman -S libpulse jsoncpp libmpdclient
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      yes | sudo pacman -Rns i3-wm
      yes | sudo pacman -S i3-gaps rofi
      yes 1 | yay -S polybar --noconfirm

      yes | sudo pacman -S scrot accountsservice
      yes | sudo pacman -Rns $(pacman -Qtdq)

      user=$(whoami)
      sudo cp -raf $DIR/../../../system-confs/account /var/lib/AccountsService/users/$user
      sudo sed -i "s/ACCOUNT_NAME/$user/g" /var/lib/AccountsService/users/$user
      sudo cp $DIR/../../../rice/images/avatar/default-user.png /var/lib/AccountsService/icons/$user.png
      sudo cp $DIR/../../../rice/images/avatar/default-user.png /usr/share/pixmaps/default-user.png
      sudo chown root:root /var/lib/AccountsService/users/$user
      sudo chown root:root /var/lib/AccountsService/icons/$user.png

      sudo chmod 644 /var/lib/AccountsService/users/$user
      sudo chmod 644 /var/lib/AccountsService/icons/$user.png

      # For more advance gestures, install: https://github.com/bulletmark/libinput-gestures
      bash $DIR/../../../setup-scripts/update-libinput.sh

      if [ ! -f $HOME/.riced ]; then
        bash $DIR/../../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml
      mkdir -p "$HOME/.config/neofetch"
      cp -raf $DIR/../../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      sudo cp -raf $DIR/../../../system-confs/index.theme /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo cp -raf $DIR/../../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

      bash $DIR/../../../setup-scripts/update-screen-detector.sh
      bash $DIR/../../../setup-scripts/update-themes.sh

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
