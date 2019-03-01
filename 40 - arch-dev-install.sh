
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

# cleaning
yes | sudo pacman -Rns $(pacman -Qtdq)
