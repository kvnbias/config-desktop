
#!/bin/bash

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

install_packages() {
  while true; do
    read -p "
NOTE: Sometimes you need to merge the configs before the packages get installed

Target: $1

[1] Install
[2] Sync
[3] Update world
[4] Auto merge configs
[5] Execute command
[6] Exit

Action:   " ipa
    case $ipa in
      1 ) sudo emerge --ask $1;;
      2 ) sudo emerge --sync;;
      3 ) sudo emerge --ask --verbose --update --deep --newuse @world;;
      4 ) yes | sudo etc-update --automode -3;;
      5 )
        while true; do
          read -p "Command to execute or [e]xit:   " cmd
          case $cmd in
            [Ee] ) break;;
            * ) $cmd;;
          esac
        done;;
      6 ) break;;
    esac
  done
}

add_ebuild() {
  sudo mkdir -p /usr/local/portage/$1/$2
  sudo cp $3 /usr/local/portage/$1/$2/
  sudo chown -R portage:portage /usr/local/portage
  pushd /usr/local/portage/$1/$2
  sudo repoman manifest
  popd
}

install_packages "x11-wm/i3 x11-misc/i3status x11-misc/i3lock x11-misc/dmenu x11-terms/rxvt-unicode"

if [ ! -f "$HOME/.riced" ];then
  mkdir -p "$HOME/.config/i3"
  cp -raf "$DIR/../../../rice/xinitrc"         "$HOME/.xinitrc"
  cp -raf "$DIR/../../../rice/base-i3-config"  "$HOME/.config/i3/config"
  cp -raf "$DIR/../../../rice/base-Xresources" "$HOME/.Xresources"
  sudo cp "$HOME/.Xresources"                  "/root/.Xresources"
fi

while true; do
  read -p "Minimal installation done. Would you like to proceed [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      if ! cat /etc/portage/package.use/flags | grep -q "ricing"; then
        cat $DIR/../../../system-confs/ricing-package.use | sudo tee -a /etc/portage/package.use/flags
      fi

      sudo mkdir -p /usr/local/portage/{metadata,profiles}
      sudo chown -R portage:portage /usr/local/portage
      echo 'local' | sudo tee /usr/local/portage/profiles/local
      sudo cp $DIR/../../../system-confs/layout.conf  /usr/local/portage/metadata/layout.conf
      sudo cp $DIR/../../../system-confs/local.conf   /etc/portage/repos.conf/local.conf

      install_packages "net-misc/curl net-misc/wget net-misc/httpie sys-process/lsof dev-vcs/git app-misc/tmux app-editors/vim app-editors/gedit"
      install_packages "app-portage/repoman"

      add_ebuild "x11-themes" "papirus-icon-theme" "$DIR/../ebuilds/papirus-icon-theme-20190331.ebuild"
      install_packages "x11-themes/papirus-icon-theme"

      install_packages "media-libs/imlib2"
      install_packages "media-gfx/feh x11-misc/arandr lxde-base/lxappearance"
      install_packages "x11-apps/xbacklight x11-apps/xrandr x11-apps/xrdb x11-apps/xinput"

      bash $DIR/../../../setup-scripts/remove-other-notification-service.sh

      install_packages "media-sound/alsa-utils media-sound/alsa-tools media-libs/alsa-lib"
      install_packages "media-sound/pulseaudio media-sound/pavucontrol"

      add_ebuild "x11-misc" "pa-applet" "$DIR/../ebuilds/pa-applet-20181009.ebuild"
      install_packages "x11-misc/pa-applet"

      sudo sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf
      sudo sed -i 's/; autospawn = yes/autospawn = yes/g' /etc/pulse/client.conf

      install_packages "net-misc/networkmanager gnome-extra/nm-applet"
      sudo systemctl enable NetworkManager

      add_ebuild "media-fonts" "nerd-fonts" "$DIR/../ebuilds/nerd-fonts-2.0.0.ebuild"
      install_packages "media-fonts/nerd-fonts"

      install_packages "app-misc/neofetch"

      add_ebuild "x11-themes" "breeze-xcursors" "$DIR/../ebuilds/breeze-xcursors-5.15.4.1.ebuild"
      install_packages "x11-themes/breeze-xcursors"

      install_packages "x11-misc/dunst app-admin/conky x11-misc/compton www-client/w3m"
      install_packages "media-video/ffmpegthumbnailer"

      # https://pillow.readthedocs.io/en/stable/installation.html
      install_packages "dev-python/pip"
      install_packages "app-text/poppler media-video/mediainfo net-p2p/transmission"
      install_packages "app-arch/zip app-arch/unzip app-arch/tar app-arch/xz-utils app-arch/unrar"
      install_packages "app-text/catdoc app-text/docx2txt"

      install_packages "media-libs/libjpeg-turbo sys-libs/zlib"
      install_packages "x11-libs/libXext dev-python/setuptools"
      pip3 install --user ueberzug

      sudo emerge --ask --verbose --depclean x11-misc/i3lock
      add_ebuild "x11-misc" "i3lock-color" "$DIR/../ebuilds/i3lock-color-2.12.ebuild"
      install_packages "x11-misc/i3lock-color"

      install_packages "app-misc/ranger app-misc/vifm"

      install_packages "sys-apps/file media-libs/libcaca dev-python/pygments app-arch/atool app-arch/libarchive app-arch/unrar www-client/lynx"
      install_packages "app-text/mupdf net-p2p/transmission media-video/mediainfo app-text/odt2txt dev-python/chardet"

      sudo emerge --ask --verbose --depclean x11-wm/i3
      install_packages "x11-misc/rofi x11-wm/i3-gaps x11-misc/polybar"

      install_packages "media-sound/mpd media-sound/mpc media-sound/ncmpcpp"
      sudo systemctl disable mpd
      sudo systemctl stop mpd

      install_packages "media-gfx/scrot sys-apps/accountsservice"
      sudo emerge --ask --depclean

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

      echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/emerge" | sudo tee -a "/etc/sudoers"

      if [ ! -f $HOME/.riced ];then
        bash $DIR/../../../setup-scripts/setup-user-configs.sh
        bash $DIR/../../../setup-scripts/update-scripts.sh
        touch $HOME/.riced
      fi

      sudo ln -sf /usr/bin/urxvt /usr/bin/urxvt256c-ml

      mkdir -p "$HOME/.config/neofetch"
      cp -rf $DIR/../../../rice/neofetch.conf $HOME/.config/neofetch/$os.conf

      sudo mkdir -p /usr/share/icons/default
      sudo cp -raf $DIR/../../../system-confs/index.theme /usr/share/icons/default/index.theme

      sudo mkdir -p /root/.vim
      sudo cp -raf $HOME/.vim/* /root/.vim
      sudo cp -raf $HOME/.vimrc /root/.vimrc

      sudo cp -rf $DIR/../../../rice/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

      bash $DIR/../../../setup-scripts/update-scripts.sh
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





