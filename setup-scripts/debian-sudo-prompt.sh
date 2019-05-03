
#!/bin/bash

if [ "$1" = "debian" ]; then
  while true; do
    echo "
If sudo is not enabled during installation (Debian). Logout this user, login as root on
tty2 (Ctrl + Alt + F2) then execute the commands below before proceeding.

apt install -y sudo libuser
groupadd wheel
usermod -aG wheel $(whoami)
usermod -aG sudo $(whoami)
usermod -g wheel $(whoami)
echo '%wheel ALL=(ALL) ALL' | tee -a /etc/sudoers
"
  read -p "Choose action: [l]ogout | [s]kip   " isu
  case $isu in
      [Ss]* ) break;;
      [Ll]* ) sudo pkill -KILL -u $(whoami);;
      * ) echo "Invalid input";;
    esac
  done
fi
