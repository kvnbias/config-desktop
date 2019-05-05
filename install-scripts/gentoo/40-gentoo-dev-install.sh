
#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo apt -y upgrade

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

# extra
sudo install_packages "sys-process/htop"

# vscode
cd /tmp

# wget -O /tmp/vscode.tar.gz https://update.code.visualstudio.com/latest/linux-x64/stable
# sudo mkdir -p /opt/vscode && sudo chmod 777 /opt/vscode
# tar xzvf /tmp/vscode.tar.gz -C /opt/vscode/
# sudo ln -sf /opt/vscode/VSCode-linux-x64/bin/code /usr/bin/code
#
# echo "
# [Desktop Entry]
# Name=Visual Studio Code
# Comment=Manually downloaded vscode
# Exec=code
# Terminal=false
# Type=Application
# Icon=" | tee $HOME/.local/share/applications/code.desktop
#
# echo "
# [Desktop Entry]
# Name=Visual Studio Code Update
# Comment=Manually downloaded vscode
# Exec=/bin/bash -c \"notify-send -i $HOME/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Downloading Visual Studio Code'; wget -O /tmp/vscode.tar.gz https://update.code.visualstudio.com/latest/linux-x64/stable; notify-send -i $HOME/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Updating Visual Studio Code'; tar xzvf /tmp/vscode.tar.gz -C /opt/vscode/; notify-send -i $HOME/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Visual Studio Code updated'\"
# Terminal=false
# Type=Application
# Icon=
# " | tee $HOME/.local/share/applications/code-update.desktop
add_ebuild "app-editors" "vscode-bin" "$DIR/ebuilds/vscode-bin-1.33.1.ebuild"
install_packages "app-editors/vscode-bin"
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

while true; do
  read -p "Enable vim mode on VSCode [yN]?   " evm
  case $evm in
    [Yy]* )
      code --install-extension vscodevim.vim &
      break;;
    *) break;;
  esac
done

# vscode theme install via cli
# code --install-extension equinusocio.vsc-material-theme
# code --install-extension pkief.material-icon-theme

# vscode docker extension
code --install-extension eamodio.gitlens &
code --install-extension peterjausovec.vscode-docker &
code --install-extension ms-vscode.theme-tomorrowkit &

sleep 20

while true; do
  read -p "

Install Google Chrome [yN]?   " igc
  case $igc in
    [Yy]* )
      sudo install_packages "www-client/google-chrome"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Zeal [yN]?   " iz
  case $iz in
    [Yy]* )
      if ! sudo cat /etc/portage/package.use/flags | grep -q 'dev-qt/qtprintsupport'; then
        echo "dev-qt/qtprintsupport cups" | sudo tee -a /etc/portage/package.use/flags
      fi

      if ! sudo cat /etc/portage/package.use/flags | grep -q ' dev-qt/qtnetwork'; then
        echo "dev-qt/qtnetwork networkmanager" | sudo tee -a /etc/portage/package.use/flags
      fi

      sudo install_packages "app-doc/zeal"
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install DBeaver [yN]?   " idbvr
  case $idbvr in
    [Yy]* )
#       cd /tmp
#       wget -O /tmp/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz
#       sudo mkdir -p /opt/dbeaver-ce && sudo chmod 777 /opt/dbeaver-ce
#       tar xzvf /tmp/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz -C /opt/dbeaver-ce/
#       sudo ln -sf /opt/dbeaver-ce/dbeaver/dbeaver /usr/bin/dbeaver
# 
#       echo "
# [Desktop Entry]
# Name=Dbeaver Community Edition
# Comment=Manually downloaded dbeaver
# Exec=dbeaver
# Terminal=false
# Type=Application
# Icon=" | tee $HOME/.local/share/applications/dbeaver.desktop
# 
#       echo "
# [Desktop Entry]
# Name=Dbeaver Community Edition Update
# Comment=Manually downloaded dbeaver
# Exec=/bin/bash -c \"notify-send -i $HOME/.config/dbeaver/noicon -t 5000 'Dbeaver Community Edition' 'Downloading Dbeaver Community Edition'; wget -O /tmp/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz; notify-send -i $HOME/.config/dbeaver/noicon -t 5000 'Dbeaver Community Edition' 'Updating Dbeaver Community Edition'; tar xzvf /tmp/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz -C /opt/dbeaver-ce/; notify-send -i $HOME/.config/debaver/noicon -t 5000 'Dbeaver Community Edition' 'Dbeaver Community Edition updated'\"
# Terminal=false
# Type=Application
# Icon=
# " | tee $HOME/.local/share/applications/dbeaver-update.desktop
      add_ebuild "dev-db" "dbeaver-ce-bin" "$DIR/ebuilds/dbeaver-ce-bin-6.0.3.ebuild"
      install_packages "dev-db/dbeaver-ce-bin"
      break;;
    * ) break;;
  esac
done

sudo emerge --ask --depclean
