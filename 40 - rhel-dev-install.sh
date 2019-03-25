
#!/bin/bash

mainCWD=$(pwd)

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

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

sudo groupadd wheel
sudo usermod -aG wheel $(whoami)
sudo usermod -g wheel $(whoami)

sudo mkdir /var/www/workspace
sudo chown -R $(whoami):wheel /var/www/workspace

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

while true; do
  read -p "

Install NodeJS [yN]?   " inode
  case $inode in
    [Yy]* )
      while true; do
        read -p "

Install via NVM [yN]?   " invm
        case $invm in
          [Yy]* )
            wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
            curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
            sudo dnf update
            sudo dnf install -y yarn --releasever=$fedver
            break 2;;
          * )
            curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
            sudo dnf update
            sudo dnf install -y nodejs yarn --releasever=$fedver
            break 2;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install PHP [yN]?   " iphp
  case $iphp in
    [Yy]* )
      while true; do
        read -p "

Install via php-build [yN]?   " iphpb
        case $iphpb in
          [Yy]* )
            git clone https://github.com/php-build/php-build.git /tmp/php-build
            cp $(pwd)/dev/php/installation/configure-options  /tmp/php-build/share/php-build/default_configure_options
            mkdir -p $HOME/.config/dev
            cp $(pwd)/dev/php/installation/switch-php.sh  $HOME/.config/dev/switch-php.sh

            if ! cat $HOME/.bashrc | grep -q "alias php-switch"; then
              echo "alias php-switch=\"\$HOME/.config/dev/switch-php.sh\"" | tee -a $HOME/.bashrc
            fi

            sudo /tmp/php-build/install.sh

            echo "
Installing build packages...

autoconf         bzip2            bzip2-devel            gcc-c++
libcurl-devel    libicu-devel     libjpeg-turbo-devel    libpng-devel
libtidy-devel    libxml2-devel    libxslt-devel          libzip-devel
make             openssl-devel    postgresql-devel       readline-devel
tar"

            sudo dnf install -y autoconf bzip2 bzip2-devel gcc-c++ libcurl-devel libicu-devel libjpeg-turbo-devel --releasever=$fedver
            sudo dnf install -y libpng-devel libtidy-devel libxml2-devel libxslt-devel libzip-devel --releasever=$fedver
            sudo dnf install -y make openssl-devel postgresql-devel readline-devel tar --releasever=$fedver
            break 2;;
          * )
            sudo dnf install -y php php-fpm composer --releasever=$fedver
            break 2;;
        esac
      done;;
    * ) break;;
  esac
done

cd $mainCWD
sudo dnf -y autoremove

