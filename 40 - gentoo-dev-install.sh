
#!/bin/bash

mainCWD=$(pwd)

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo apt -y upgrade

# extra
sudo apt install -y --no-install-recommends htop

# vscode
cd /tmp

wget -O /tmp/vscode.tar.gz https://update.code.visualstudio.com/latest/linux-x64/stable
sudo mkdir -p /opt/vscode && sudo chmod 777 /opt/vscode
tar xzvf /tmp/vscode.tar.gz -C /opt/vscode/
sudo ln -sf /opt/vscode/VSCode-linux-x64/bin/code /usr/bin/code

echo "
[Desktop Entry]
Name=Visual Studio Code
Comment=Manually downloaded vscode
Exec=code
Terminal=false
Type=Application
Icon=" | tee /home/kev/.local/share/applications/code.desktop

echo "
[Desktop Entry]
Name=Visual Studio Code Update
Comment=Manually downloaded firefox
Exec=/bin/bash -c \"notify-send -i /home/$(whoami)/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Downloading Visual Studio Code'; wget -O /tmp/vscode.tar.gz https://update.code.visualstudio.com/latest/linux-x64/stable; notify-send -i /home/$(whoami)/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Updating Visual Studio Code';tar xzvf /tmp/vscode.tar.gz -C /opt/vscode/; notify-send -i /home/$(whoami)/.config/vscode/noicon -t 5000 'Visual Studio Code' 'Visual Studio Code updated'\"
Terminal=false
Type=Application
Icon=
" | tee /home/kev/.local/share/applications/code-update.desktop

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
      sudo apt install -y --no-install-recommends fonts-liberation
      cd /tmp
      wget  -O "google-chrome-stable_current_amd64.deb"  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb 
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Zeal [yN]?   " iz
  case $iz in
    [Yy]* )
      sudo apt install -y --no-install-recommends zeal
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install DBeaver [yN]?   " idbvr
  case $idbvr in
    [Yy]* )
      cd /tmp
      wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
      echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
      sudo apt update
      sudo apt install --no-install-recommends dbeaver-ce
      break;;
    * ) break;;
  esac
done

cd $mainCWD
sudo apt -y autoremove
