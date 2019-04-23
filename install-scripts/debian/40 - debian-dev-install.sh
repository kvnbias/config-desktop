
#!/bin/bash

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

sudo apt -y upgrade

# extra
sudo apt install -y --no-install-recommends htop

# vscode
cd /tmp
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt install --no-install-recommends apt-transport-https
sudo apt update
sudo apt install --no-install-recommends code

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

sudo apt -y autoremove
