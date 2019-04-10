
#!/bin/bash
# NOTE this script is only tested in my machines

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))

while true; do
  read -p "Will boot with other linux distros and share a partitions [yN]?   " wdb
  case $wdb in
    [Yy]* )
      while true; do
        echo "

NOTE: Use a UID that will less likely be used as an ID by other distros (e.g. 1106).
This UID will also be used on the other distro installations

"
        read -p "Enter UID or [e]xit:   " uid
        case $uid in
          [Ee]* ) break;;
          * )
            while true; do
              echo "

NOTE: Use a GUID that will less likely be used as an ID by other distros (e.g. 1106).
This GUID will also be used on the other distro installations

"
              read -p "Enter GUID or [e]xit:   " guid
              case $guid in
                [Ee]* ) break 2;;
                * )
                  while true; do
                    echo "

Logout this user account and execute the commands below as a root user on tty2 (Ctrl + Alt + F2):

groupadd wheel
usermod -u $uid $(whoami)
groupmod -g $guid wheel
usermod -g wheel $(whoami)
chown -R $(whoami):wheel /home/$(whoami)

"
                    read -p "Choose action: [l]ogout | [s]kip   " wultp
                    case $wultp in
                      [Ss]* ) break 4;;
                      [Ll]* ) sudo pkill -KILL -u $(whoami);;
                      * ) echo "Invalid input";;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    * ) break;;
  esac
done

if [ "$os" = "debian" ]; then
  if cat /etc/apt/sources.list | grep -q "main contrib non-free"; then
    echo "Non-free repos already added."
  else
    sudo sed -i "s/main.*/main contrib non-free/g" /etc/apt/sources.list
    echo "Non-free repos added."
  fi
fi

sudo zypper refresh
sudo zypper -n update

sudo zypper -n install --no-recommends kernel-devel

## Start swap initialization
while true; do
  lsblk
  read -p "Initialize swap partition. If not mounted [yN]   " yn
  case $yn in
    [Yy]* )
      while true; do
        sudo fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * ) sudo mkswap $td;sudo swapon $td; break;;
        esac
      done;;
    * ) break;;
  esac
done

sudo zypper -n install --no-recommends numlockx
sudo zypper -n install --no-recommends xdg-user-dirs

if [ ! -d "/home/$(whoami)/Desktop" ];then
  xdg-user-dirs-update
fi

# Hibernation
if [ -f /etc/default/grub ]; then
  sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub

  if cat /etc/default/grub | grep -q 'GRUB_SAVEDEFAULT'; then
    sudo sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/g' /etc/default/grub
  else
    echo 'GRUB_SAVEDEFAULT="true"' | sudo tee -a /etc/default/grub
  fi

  if sudo cat /etc/default/grub | grep -q 'resume='; then
    echo "Hibernation already enabled..."
  else
    while true; do
      read -p "Do you like to enable hibernation [Yn]?   " yn
      case $yn in
        [Nn]* ) break;;
        * )
        while true; do
            sudo fdisk -l;
            read -p "What device to use (e.g. /dev/sdXn) or [e]xit   ?   " dvc
            case $dvc in
            [Ee]* ) break;;
            * )
                sudo sed -i "s~GRUB_CMDLINE_LINUX=\"~GRUB_CMDLINE_LINUX=\"resume=$dvc ~g" /etc/default/grub
                break 2;;
            esac
        done;;
      esac
    done

    while true; do
      read -p "Update GRUB [Yn]?   " updgr
      case $updgr in
        [Nn]* ) break;;
        * ) sudo grub2-mkconfig -o /boot/grub2/grub.cfg; break;;
      esac
    done
  fi
fi

sudo zypper -n install --no-recommends acpid
sudo systemctl enable acpid

sudo zypper -n install --no-recommends pciutils usbutils

echo '

####################################
####################################
###                              ###
###    INSTALLATION COMPLETE     ###
###    BETTER INSTALL DISPLAY    ###
###    SERVERS NOW ...           ###
###                              ###
####################################
####################################

'
