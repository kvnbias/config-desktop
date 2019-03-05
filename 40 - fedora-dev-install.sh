
#!/bin/bash

mainCWD=$(pwd)

if [ "$1" = "" ];then
  fedver=$(rpm -E %fedora)
else
  fedver=$1
fi

sudo dnf -y upgrade

# extra
sudo dnf install -y htop --releasever=$fedver

# vscode
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code --releasever=$fedver
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
      sudo sh -c 'echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
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
      sudo dnf install -y dbeaver-ce-latest-stable.x86_64.rpm
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install NVM (NodeJS) [yN]?   " invm
  case $invm in
    [Yy]* )
      wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install PHP-Build (PHP) [yN]?   " invm
  case $invm in
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
Already Installed:

aspell    curl      db           enchant            gmp
icu       libnsl    libsodium    libtool            libxslt
libzip    pcre2     sqlite       postgresql-libs    procps-ng
tidy

Enter any key to proceed...   " eak
        case $eak in
          * ) break;;
        esac
      done
      yes | sudo pacman -S aspell curl db enchant gmp icu libnsl libsodium libtool
      yes | sudo pacman -S libxslt libzip pcre2 sqlite postgresql-libs procps-ng tidy
      break;;
    * ) break;;
  esac
done

cd $mainCWD
sudo dnf autoremove
