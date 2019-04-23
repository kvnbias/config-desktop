
#!/bin/bash

sudo restorecon -prF /
sudo systemctl enable restorecond
sudo systemctl enable auditd
sudo systemctl start restorecond
sudo systemctl start auditd

yes | sudo pacman -Rns $(pacman -Qtdq)

echo '



###################################
INSTALLATION FINISHED. TODO:
> Reboot.
###################################



'

while true; do
  read -p "Reboot now [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      sudo reboot;
      break;;
  esac
done
