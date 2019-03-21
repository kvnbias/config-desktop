
#!/bin/bash

mainCWD=$(pwd)

os=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

sudo apt -y upgrade

# extra
sudo apt install -y --no-install-recommends htop

sudo groupadd wheel
sudo usermod -aG wheel $(whoami)
sudo usermod -g wheel $(whoami)

sudo mkdir /var/www/workspace
sudo chown -R $(whoami):wheel /var/www/workspace

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

# vscode theme install via cli
# code --install-extension equinusocio.vsc-material-theme
# code --install-extension pkief.material-icon-theme

# vscode docker extension
code --install-extension eamodio.gitlens &
code --install-extension peterjausovec.vscode-docker &
code --install-extension ms-vscode.theme-tomorrowkit &

while true; do
  read -p "

Install Google Chrome [yN]?   " igc
  case $igc in
    [Yy]* )
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
            sudo apt install -y --no-install-recommends yarnpkg
            break 2;;
          * )
            sudo apt install -y --no-install-recommends nodejs yarnpkg
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

            while true; do
              read -p "
Installing build packages...

autoconf               bison          bzip2                   g++
libbison-dev           libbz2-dev     libcurl4-openssl-dev    libicu-dev
libjpeg62-turbo-dev    libpng-dev     llibpq-dev              libreadline-dev
libssl-dev             libtidy-dev    libxml2-dev             libxslt1-devel
libzip-dev             make           re2c                    tar

Enter any key to proceed...   " eak
              case $eak in
                * ) break;;
              esac
            done

            sudo apt install -y --no-install-recommends autoconf bzip2  g++ libbz2-dev libcurl4-openssl-dev libicu-dev libjpeg62-turbo-dev
            sudo apt install -y --no-install-recommends libpng-dev llibpq-dev libreadline-dev libssl-dev libtidy-dev libxml2-dev libxslt1-devel libzip-dev
            sudo apt install -y --no-install-recommends bison libbison-dev make tar re2c
            break 2;;
          * )
            sudo apt install -y --no-install-recommends php7.3 php-fpm composer
            break 2;;
        esac
      done;;
    * ) break;;
  esac
done

cd $mainCWD
sudo apt -y autoremove
