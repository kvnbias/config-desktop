
#!/bin/bash

mainCWD=$(pwd)

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

sudo dnf -y upgrade

# extra
sudo dnf install -y htop --releasever=$fedver

# vscode
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf update
sudo dnf install -y code --releasever=$fedver
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
      sudo sh -c 'echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
      sudo dnf update
      sudo dnf install -y google-chrome-stable --releasever=$fedver
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Zeal [yN]?   " iz
  case $iz in
    [Yy]* )
      sudo dnf install -y zeal --releasever=$fedver
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
      wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
      sudo dnf install -y dbeaver-ce-latest-stable.x86_64.rpm --releasever=$fedver
      break;;
    * ) break;;
  esac
done

cd $mainCWD
sudo dnf -y autoremove

