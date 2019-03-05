
#!/bin/bash

# update all
sudo pacman -Syu

# extra
yes | sudo pacman -S htop

# vscode
yes | sudo pacman -S code

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
      yes | yay -S google-chrome --noconfirm
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install Zeal [yN]?   " iz
  case $iz in
    [Yy]* )
      yes | sudo pacman -S zeal
      break;;
    * ) break;;
  esac
done

while true; do
  read -p "

Install DBeaver [yN]?   " idbvr
  case $idbvr in
    [Yy]* )
      yes | sudo pacman -S dbeaver
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
      yes | sudo pacman -S yarn
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

# cleaning
yes | sudo pacman -Rns $(pacman -Qtdq)
