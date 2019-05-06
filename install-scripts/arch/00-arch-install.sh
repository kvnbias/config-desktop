#!/bin/bash
# NOTE this script is only tested in my machines

echo "Checking if UEFI mode is enabled..."

if [ -d /sys/firmware/efi/efivars ]; then
  echo "UEFI mode is enabled..."
else
  echo "UEFI mode is not enabled..."
fi

while true; do
  read -p "Do you want to proceed [Yn]?   " p
  case $p in
    [Nn]* )
      if [ -d /sys/firmware/efi/efivars ]; then
        echo "UEFI mode is enabled..."
      else
        echo "UEFI mode is not enabled..."
      fi
      ;;
    * ) break;;
  esac
done

## Start keymap
while true; do
  read -p "Set keyboard keymap (e.g. us, de_latin1)   " l
  case $l in
    * )
      if ls /usr/share/kbd/keymaps/**/* | grep "^$l.map.gz$"; then
        while true; do
          read -p "Are you sure you want to set $l as your keymap [Yn]?   " yn
          case $yn in
            [Nn]* ) break;;
            * ) loadkeys $l; echo "Keymap set to $l";
              break 2;;
          esac
        done;
      else
        echo "Keymap doesnt exist"
      fi
  esac
done
## End keymap

timedatectl set-ntp true

## Start partition management
echo '


Partitions:
'

parted -l


while true; do
  read -p "

HD PARTITION

Choose partition action:
    [s]how all
    [l]abel
    show [f]ree
    [d]elete
    [c]reate
    [n]ame
    [m]ake flag
    f[o]rmat
    [p]roceed

Enter action:   " slfdcmop
  case $slfdcmop in
    [Ss]* ) echo '
      
      
      '
      parted -l
      echo '
      
      
      ';;
    [Ll]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Partition label (e.g. gpt, msdos) or [e]xit   " pl
              case $pl in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Relabeling a partition will delete ALL of its contents. Do you want to continue [yN]?   " yn
                    case $yn in
                      [Yy]* ) parted -s $tp mklabel $pl
                        echo '
                        
                        
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                      * ) break 3;;
                    esac
                  done
              esac
            done;;
        esac
      done;;
    [Ff]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX)   " tp
        case $tp in
          * ) echo '
          
          
          '
          parted -s $tp print free
          echo '
          
          
          '
          break;;
        esac
      done;;
    [Dd]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * ) echo $tp
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Are you sure you want to delete $tp Num $pn [yN]?   " yn
                    case $yn in
                      [Yy]* ) echo Deleting Partition $tp Num $pn
                        parted -s $tp rm $pn
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                      * ) echo No
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Cc]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Filesysten type (e.g. fat32, ext4, linux-swap, HFS) or [e]xit   " fs
              case $fs in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "


Starting point -- Examples:
1. 0% - If this is your 1st partition
2. 512MiB - If your last partition ends on 512MB

Units available are: s (sectors), B (bytes), kBm kiB, MB, MiB, GB, GiB, TB, TiB, %

or [e]xit

Enter starting point:   " sp
                    case $sp in
                      [Ee] ) break 3;;
                      * )
                        while true; do
                          read -p "


Ending point -- Examples:
1. 512MiB - If this is your first partition and you want to make it 512MB
2. 1024MiB - If your starting point is 512MB (first partition size is 512MiB) then create this partition as another 512MiB.
3. 100% - use all remaining free space.

Units available are: s (sectors), B (bytes), kBm kiB, MB, MiB, GB, GiB, TB, TiB, %

or [e]xit

Enter ending point:   " ep
                          case $ep in
                            [Ee] ) break 4;;
                            * ) parted -s $tp mkpart primary $fs $sp $ep;
                            echo '
                            
                            '
                            parted -l
                            echo '
                            
                            '
                            break 4;;
                          esac
                        done;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Nn]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * ) echo $tp
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Partition name   " nm
                    case $nm in
                      * )
                        parted $tp name $pn $nm
                        echo '
                        
                        
                        Partitions:
                        '
                        parted -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Mm]* )
      while true; do
        read -p "Target partition (e.g. /dev/sdX) or [e]xit   " tp
        case $tp in
          [Ee] ) break;;
          * )
            while true; do
              parted -l
              read -p "Partition number or [e]xit   " pn
              case $pn in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Flag (e.g. esp, boot, root, swap) or [e]xit   " pf
                    case $pf in
                      [Ee] ) break 3;;
                      * )
                        while true; do
                          read -p "State (e.g. on, off) or [e]xit   " ps
                          case $ps in
                            [Ee] ) break 4;;
                            * ) parted -s $tp set $pn $pf $ps;
                            echo '
                            
                            
                            '
                            parted -l
                            echo '
                            
                            
                            '
                            break 4;;
                          esac
                        done;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Oo]* )
      while true; do
        fdisk -l
        read -p "Choose device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Filesystem type by mkfs (e.g. vfat, ext4) or [e]xit   " fs
              case $fs in
                [Ee] ) break 2;;
                * )
                  while true; do
                    read -p "Options[not required] (e.g. -F32) or [e]xit   " o
                    case $o in
                      [Ee] ) break 3;;
                      * ) mkfs.$fs $o $td;
                        echo '
                        
                        
                        '
                        fdisk -l
                        echo '
                        
                        
                        '
                        break 3;;
                    esac
                  done;;
              esac
            done;;
        esac
      done;;
    [Pp]* )
      while true; do
        read -p "Are you sure you want to proceed with the installation [yN]?   " yn
        case $yn in
          [Yy]* ) echo '
            
            
            Partitions:
            '
            parted -l
            echo '
            
            
            '
            break 2;;
          * ) break;;
        esac
      done;;
    * ) echo 'Invalid input'
  esac
done
## End partition management

## Start swap initialization
while true; do
  read -p "Initialize swap partition [yN]   " yn
  case $yn in
    [Yy]* )
      while true; do
        fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * ) mkswap $td; swapon $td; break;;
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "

MOUNTING

NOTE: Mount your root partition before anything else. Mount your boot
partition here

Do you want to mount partitions [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * )
      while true; do
        echo "Mount your root partition before mounting the boot partition"
        fdisk -l
        read -p "Target device (e.g. /dev/sdXn) or [e]xit   " td
        case $td in
          [Ee] ) break;;
          * )
            while true; do
              read -p "Mount point (e.g. /) or [e]xit   " mp
              case $mp in
                [Ee] ) break 2;;
                * ) mkdir -p /mnt$mp; mount $td /mnt$mp; break 2;;
              esac
            done;;
        esac
      done;;
  esac
done
## End swap initialization

## Start mirror management
while true; do
  read -p "

MIRRORS

Do you want to disable all mirrors then reactivate the ones you prefer later [Yn]?   " yn
  case $yn in
    [Nn]* ) break;;
    * ) sed -i 's/^/#/g' /etc/pacman.d/mirrorlist; echo "Mirrors disabled"; break;;
  esac
done

while true; do
  read -p "

Select action:
  [r]eactivate mirror
  [d]eactivate mirror
  [e]xit

Enter action:   " a
  case $a in
    [Ee]* ) break;;
    [Rr]* )
      while true; do
        read -p "Enter country (e.g. United States, Japan) or [e]xit   " ec
        case $ec in
          [Ee] ) break;;
          * ) sed -i ":a;N;\$!ba;s/### $ec\n#Server/## $ec\nServer/g" /etc/pacman.d/mirrorlist;
          echo "$ec activated."; break;;
        esac
      done;;
    [Dd]* )
      while true; do
        read -p "Enter country (e.g. United States, Japan) or [e]xit   " ec
        case $ec in
          [Ee] ) break;;
          * ) sed -i ":a;N;\$!ba;s/## $ec\nServer/### $ec\n#Server/g" /etc/pacman.d/mirrorlist;
          echo "$ec deactivated."; break;;
        esac
      done;;
  esac
done
## End mirror management

pacstrap /mnt base wget git vim base-devel networkmanager
genfstab -U /mnt >> /mnt/etc/fstab


# echo script before going to chroot
echo "
#!/bin/bash

while true; do
  read -p \"Set timezone (e.g. America/Chicago)   \" tz
  case \$tz in
    * )
      if [[ \$tz =~ ^[a-zA-Z]+/[a-zA-Z]+$ ]]; then
        if ls /usr/share/zoneinfo/\$tz 2>/dev/null; then
          ln -sf /usr/share/zoneinfo/\$tz /etc/localtime;
          break;
        else
          echo Timezone doesnt exist
        fi
      else
        echo Invalid input
      fi
  esac
done

hwclock --systohc

while true; do
  read -p \"Actions: [a]ctivate locales | [d]eactivate locales | [g]enerate locales | [e]xit   \" a
  case \$a in
    [Aa] )
      while true; do
        read -p \"Activate locale (e.g. 'en_US.UTF-8 UTF-8') or [e]xit   \" al
        case \$al in
          [Ee] ) break;;
          * ) sed -i \"s/^#\$al/\$al/g\" /etc/locale.gen
            echo Activated \$al;
            break;;
        esac
      done;;
    [Dd] )
      while true; do
        read -p \"Deactivate locale (e.g. 'en_US.UTF-8 UTF-8') or [e]xit   \" dl
        case \$dl in
          [Ee] ) break;;
          * ) sed -i \"s/^\$dl/#\$dl/g\" /etc/locale.gen
            echo Dectivated \$dl;
            break;;
        esac
      done;;
    [Gg] ) locale-gen;;
    [Ee] ) break;;
    * ) echo Invalid input
  esac
done

while true; do
  read -p \"Set LANG (e.g. 'en_US.UTF-8') or [e]xit   \" l
  case \$l in
    [Ee] ) break;;
    * ) echo \"LANG=\$l\" | tee /etc/locale.conf;;
  esac
done

while true; do
  read -p \"Set KEYMAP (e.g. us, de-latin1) or [e]xit   \" k
  case \$k in
    [Ee] ) break;;
    * ) echo \"KEYMAP=\$k\" | tee /etc/vconsole.conf;;
  esac
done

while true; do
  read -p \"Enter hostname or [e]xit   \" hn
  case \$hn in
    [Ee] ) break;;
    * )
      if test -z \"\$hn\"; then
        echo Invalid input
      else
        echo \$hn | tee /etc/hostname && echo \"

127.0.0.1    localhost
::1          localhost
127.0.1.1    \$hn.localdomain \$hn

\" | tee /etc/hosts;
      fi
  esac
done

echo '

###################################
###################################
###                             ###
###        SET PASSWORD         ###
###                             ###
###################################
###################################

'

passwd

installBootLoader=true
while true; do
  read -p \"Do you want to install a bootloader [Yn]?    \" ibl
  case \$ibl in
    [Nn] ) installBootLoader=false; break;;
    * ) installBootLoader=true; break;;
  esac
done

if [[ \"\$installBootLoader\" = \"true\" ]]; then
  while true; do
    read -p \"Are you using UEFI + GPT partition? [y]es | [n]o   \" yn
    case \$yn in
      [Yy]* )
        while true; do
          read -p \"EFI directory (e.g. /boot/efi) or [e]xit   \" ed
          case \$ed in
            [Ee] ) break;;
            * )
              if [ -d \$ed ]; then
                while true; do
                  read -p \"

Choose bootloader

[a] rEFInd
[*] GRUB

Enter bootloader [default=GRUB]:   \" bl
                  case \$bl in
                    [Aa] )
                      yes | pacman -S refind-efi efibootmgr
                      refind-install

                      mkdir -p \$ed/EFI/boot
                      cp -a \$ed/EFI/refind/refind_x64.efi \$ed/EFI/boot/bootx64.efi
                      echo '
bcf boot add 1 fs0:\EFI\refind\refind_x64.efi \"Fallback Bootloader\"
exit' | tee \$ed/startup.nsh

                      root=\$(mount -v | grep 'on / ' | cut -f 1 -d ' ')
                      uuid=\$(blkid | grep \$root | cut -f 2 -d ' ')

                      if [[ \$uuid == *\"LABEL\"* ]]; then
                        uuid=\$(blkid | grep \$root | cut -f 3 -d ' ')
                      fi

                      if [[ \$uuid != *\"UUID\"* ]]; then
                        uuid=\$root
                      fi

                      uuid=\$(echo \$uuid | sed 's/\"//g')

                      echo \"
\\\"Boot with standard options\\\"  \\\"root=\$uuid rw\\\"
\\\"Boot to single-user mode\\\"    \\\"root=\$uuid rw single\\\"
\\\"Boot with minimal options\\\"   \\\"ro root=\$uuid\\\"
\" | tee /boot/refind_linux.conf

                      while true; do
                        read -p \"Would you like to rice rEFInd [Yn]?   \" rrfnd
                        case \$rrfnd in
                          [Nn] ) break 4;;
                          * )
                            git clone https://github.com/kvnbias/refind-theme /tmp/refind-theme
                            sudo mkdir -p \$ed/EFI/refind/themes/refind-theme
                            sudo cp -raf --no-preserve=mode,ownership /tmp/refind-theme/* \$ed/EFI/refind/themes/refind-theme
                            echo 'include themes/refind-theme/theme.conf' | sudo tee -a \$ed/EFI/refind/refind.conf
                            break 4;;
                        esac
                      done;;
                    * )
                      yes | pacman -S grub efibootmgr
                      grub-install --target=x86_64-efi --efi-directory=\$ed --bootloader-id=GRUB;
                      grub-mkconfig -o /boot/grub/grub.cfg

                      mkdir -p \$ed/EFI/boot
                      cp -a \$ed/EFI/GRUB/grubx64.efi \$ed/EFI/boot/bootx64.efi
                      echo '
bcf boot add 1 fs0:\EFI\GRUB\grubx64.efi \"Fallback Bootloader\"
exit' | tee \$ed/startup.nsh

                      echo Installed GRUB in UEFI mode;
                      break 3;;
                  esac
                done;
              else
                echo EFI Directory doesnt exist;
                break;
              fi
          esac
        done;;
      [Nn]* )
        while true; do
          echo '

          '
          fdisk -l
          echo '

          '
          read -p \"Target device (e.g. /dev/sdX) or [e]xit   \" td
          case \$td in
            [Ee] ) break;;
            * )
              pacman -S grub
              grub-install --target=i386-pc \$td;
              grub-mkconfig -o /boot/grub/grub.cfg
              echo Installed GRUB in LEGACY mode;
              break 2;;
          esac
        done;;
      * ) echo Invalid input;;
    esac
  done
fi

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers


while true; do
  read -p \"Would you like to create a new user [yN]?   \" yn
  case \$yn in
    [Yy]* )
      while true; do
        read -p \"Enter username or [e]xit   \" un
        case \$un in
          [Ee] ) break;;
          * )
            if [[ \$un =~ ^[a-z]+$ ]]; then
              useradd -m -g wheel \$un && passwd \$un;
              echo Added \$un
              break;
            else
              echo Invalid input. Lowercase letters only.
            fi
        esac
      done;;
    * ) break;;
  esac
done

systemctl enable NetworkManager

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bup
yes | sudo pacman -S reflector


while true; do
  read -p \"Would you like to refresh mirrors [yN]?   \" yn
  case \$yn in
    [Yy]* )
      sudo reflector --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
      break;;
    * ) break;;
  esac
done


echo '

###################################
###################################
###                             ###
###    INSTALLATION COMPLETE    ###
###    YOU CAN REBOOT NOW...    ###
###                             ###
###################################
###################################

'




































" | tee /mnt/arch-install;


echo '

###################################
###################################
###                             ###
###  EXECUTE bash arch-install  ###
###  UPON ENTERING THE CHROOT   ###
###                             ###
###################################
###################################

'


arch-chroot /mnt
