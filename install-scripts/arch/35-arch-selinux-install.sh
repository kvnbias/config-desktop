
#!/bin/bash
# This module can be executed immediately after arch post installation

while true; do
  read -p "


NOTE:

SELinux Policies for Arch is barebones compared to other distros (e.g. Fedora).
While you can install policies created by other distros, the compatibility
in Arch is not guaranteed. If you do mind want a barebones SELinux, proceed.


Proceed anyway [yN]?   " yn
  case $yn in
    [Yy]* ) break;;
    * ) exit 1;;
  esac
done

# install AUR helper: yay
git clone https://aur.archlinux.org/yay.git
cd yay
yes | makepkg --syncdeps --install
cd ..
rm -rf yay

isManjaro=false
while true; do
  read -p "Using manjaro [yN]?   " p
  case $p in
    [Yy]* )
      isManjaro=true;
      break;;
    * ) break;;
  esac
done

if [ "$isManjaro" = true ]; then
  major=$(uname -r | cut -f 1 -d .);
  minor=$(uname -r | cut -f 2 -d .);
  version=$(echo $major$minor);
  yes | sudo pacman -S linux$version linux$version-headers;
else
  while true; do
    read -p "What kernel? [l]ts | [n]ormal | [b]oth | [s]kip   " ilts
    case $ilts in
      [Ll]* )
        yes | sudo pacman -S linux-lts linux-lts-headers
        break;;
      [Nn]* )
        yes | sudo pacman -S linux linux-headers
        break;;
      [Bb]* )
        yes | sudo pacman -S linux linux-headers
        yes | sudo pacman -S linux-lts linux-lts-headers
        break;;
      [Ss]* )
        break;;
      * ) echo Invalid input
    esac
  done;
fi

if [ -f /etc/default/grub ]; then
  sudo grub-mkconfig -o /boot/grub/grub.cfg;
fi

while true; do
  read -p "

Use archlinuxhardened/selinux [Yn]?   " ualh
  case $ualh in
    [Nn]* )
      user=$(whoami)
      sudo cp /etc/sudoers /home/$user/sudoers
      sudo sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /home/$user/sudoers
      echo 'Defaults timestamp_timeout=-1' | sudo tee -a /etc/sudoers
      echo 'Defaults timestamp_timeout=-1' | sudo tee -a /home/$user/sudoers

      # SELINUX INSTALLATION
      #
      # delete mlocate first to prevent conflict later since yay
      # can only delete findutils, will be replaced by findutils-selinux
      yes | sudo pacman -Rns mlocate

      yes | yay -S libsepol
      yes | yay -S libselinux
      yes | yay -S secilc
      yes | yay -S checkpolicy
      yes | yay -S setools
      yes | yay -S libsemanage
      yes | yay -S semodule-utils
      yes | yay -S policycoreutils
      yes | yay -S python-ipy
      yes | yay -S selinux-python
      yes | yay -S mcstrans
      yes | yay -S restorecond

      yes | yay -S pambase-selinux
      yes | yay -S pam-selinux

      yes | yay -S coreutils-selinux
      yes | yay -S findutils-selinux
      yes | yay -S iproute2-selinux
      yes | yay -S logrotate-selinux
      yes | yay -S openssh-selinux
      yes | yay -S psmisc-selinux
      yes | yay -S shadow-selinux
      yes | yay -S cronie-selinux

      while true; do
        read -p "

INTERACTION NEEDED!

Go to tty 2 [Ctrl+Alt+F2] then log in as root. To go back here, press [Ctrl+Alt+F1/F7].
Upon login go back to this tty then proceed.


Would you like to proceed [Yn]?


      " yn
        case $yn in
          [Nn]* ) echo "Go to tty 2 and login as root";;
          *) break;;
        esac
      done

      yes | yay -S sudo-selinux

      while true; do
        read -p "

INTERACTION NEEDED!

Go to tty 2 [Ctrl+Alt+F2] then execute the command below then proceed:
cp /home/$user/sudoers /etc/sudoers


Would you like to proceed [Yn]?


      " yn
        case $yn in
          [Nn]* ) echo "Go to tty 2 and copy the sudoers file";;
          *) break;;
        esac
      done

      sudo rm /home/$user/sudoers


      while true; do
        read -p "

NOTE:

If the systemd/libsystemd installation failed, you may
need to downgrade your systemd.

You can downgrade by:
yay -S downgrade
downgrade systemd

Proceed [Yn]?


      " yn
        case $yn in
          [Nn]* ) echo "Ok";;
          *) break;;
        esac
      done

      git clone https://aur.archlinux.org/systemd-selinux.git
      cd systemd-selinux
      yes | makepkg -s -C
      yes | yay -S libsystemd-selinux
      cd ..

      yes | yay -S util-linux-selinux
      yes | yay -S libutil-linux-selinux
      yes | yay -S systemd-selinux

      yes | yay -S dbus-selinux
      yes | yay -S selinux-alpm-hook

      yes | yay -S selinux-refpolicy-src
      yes | yay -S selinux-refpolicy-arch
      yes | yay -S selinux-refpolicy-git

      sudo restorecon -rF /

      sudo sed -i 's/Defaults timestamp_timeout=-1/# Defaults timestamp_timeout=-1/g' /etc/sudoers

      rm -rf systemd-selinux

      break;;
    * )

      # SELINUX INSTALLATION
      #
      # delete mlocate first to prevent conflict later since yay
      # can only delete findutils, will be replaced by findutils-selinux
      yes | sudo pacman -Rns mlocate

      sudo sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /home/$user/sudoers
      echo 'Defaults timestamp_timeout=-1' | sudo tee -a /etc/sudoers

      git clone https://github.com/archlinuxhardened/selinux hardened-selinux
      cd hardened-selinux
      bash recv_gpg_keys.sh
      bash build_and_install_all.sh
      cd ..
      rm -rf hardened-selinux

      sudo sed -i 's/Defaults timestamp_timeout=-1/# Defaults timestamp_timeout=-1/g' /etc/sudoers
      
      break;;
  esac
done

if [ -f /etc/default/grub ]; then
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="security=selinux selinux=1 /g' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

while true; do
  read -p "

NOTE: This custom module is tailored on my own use case.
While most of the packages installed in this scripts will
most likely be allowed, other programs will most likely need
auditing. It's better to leave the system on a permissive state.

Do you want to install custom base module [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      echo "usepasswd = False" | sudo tee -a /etc/selinux/semanage.conf
      cp $DIR/../../selinux/cse-arch.te $DIR/../../selinux/cse-arch.te
      sudo checkmodule -M -m -o $DIR/../../selinux/cse-arch.mod $DIR/../../selinux/cse-arch.te
      sudo semodule_package -o $DIR/../../selinux/cse-arch.pp -m $DIR/../../selinux/cse-arch.mod
      sudo semodule -i $DIR/../../selinux/cse-arch.pp

      sudo rm cse-arch.te
      sudo rm cse-arch.mod
      sudo rm cse-arch.pp
      break;;
  esac
done

echo '



###################################
INSTALLATION FINISHED. TODO:
> Reboot.
> Execute the following:
    sudo restorecon -rF /
    sudo systemctl enable restorecond
    sudo systemctl enable auditd
    sudo systemctl start restorecond
    sudo systemctl start auditd
> Reboot.

OR REBOOT THEN EXECUTE: script 37
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
