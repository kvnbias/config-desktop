
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

while true; do
  read -p "This script is meant to install Gentoo with systemd. Do you want to proceed [Yn]?   " p
  case $p in
    [Nn]* ) echo "Quit";;
    * ) break;;
  esac
done

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
                * ) mkdir -p /mnt/gentoo$mp; mount $td /mnt/gentoo$mp; break 2;;
              esac
            done;;
        esac
      done;;
  esac
done
## End swap initialization

## Date
while true; do
  date
  read -p "If the date is wrong, run ntpd. Run ntpd [yN]?   " rntpd
  case $rntpd in
    [Yy]* ) ntpd -q -g; break;;
    * ) break;;
  esac
done

cd /mnt/gentoo

while true; do
  read -p "
Download the Stage 3 tarball. Follow the steps bellow:

1. Open tty2 terminal (Ctrl + Alt + F2), you can go back here (tty1) by pressing (Ctrl + Alt + F1)
2. Execute 'cd /mnt/gentoo && links https://www.gentoo.org/downloads/mirrors/'
3. Go to a mirror link (Preferably you country)
4. Navigate to: releases > amd64 > autobuilds > current-stage3-amd64-systemd
5. Save stage3-amd64-systemd-<build-id>.tar.bz2
6. Go back to tty1 (Ctrl + Alt + F1) after downloading and proceed

Proceed [yN]   " tbd
  case $tbd in
    [Yy]* )
      tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner;
      rm stage3-*;
      break;;
    * ) ;;
  esac
done

while true; do
  grep -m1 -A3 "vendor_id" /proc/cpuinfo
  read -p "
https://wiki.gentoo.org/wiki/Safe_CFLAGS
Update CPU Flags [yN]?   " ucpuf
  case $ucpuf in
    [Yy]* )
      chost=
      cflags=
      mkopts=
      useflg=

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "CHOST"; then
          cchost=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^CHOST' | head -1)
          echo "Current: $cchost"
        fi
        read -p "Enter CHOST or [e]xit:   " chst
        case $chst in
          [Ee] ) break;;
          * ) chost="$chst"; break;;
        esac
      done

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "COMMON_FLAGS"; then
          ccflags=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^COMMON_FLAGS' | head -1)
          echo "Current: $ccflags"
        fi
        read -p "Enter COMMON_FLAGS or [e]xit:   " cflgs
        case $cflgs in
          [Ee] ) break;;
          * ) cflags="$cflgs"; break;;
        esac
      done

      while true; do
        if cat /mnt/gentoo/etc/portage/make.conf | grep -q "MAKEOPTS"; then
          cmkopts=$(cat /mnt/gentoo/etc/portage/make.conf | grep '^MAKEOPTS' | head -1)
          echo "Current: $cmkopts"
        fi
        read -p "How many threads would like to use or [e]xit   " numt
        case $numt in
          [Ee]* ) break;;
          * )
            if [[ $numt =~ ^[0-9]+$ ]]; then
              mkopts="-j$numt";
              break;
            else
              echo Invalid number;
              break;
            fi
            echo '';;
        esac
      done

      while true; do
        read -p "Add my custom USE flags [yN]?   " acuf
        case $acuf in
          [Yy] ) useflg="systemd"; break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "
Changes:

CHOST=\"$chost\"
COMMON_FLAGS=\"$cflags\"
MAKEOPTS=\"$mkopts\"
USE=\"$useflg\"

Commit [yN]?   " cmtchng
        case $cmtchng in
          [Yy]* )
            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "CHOST"; then
              sed -i "s/CHOST=.*/CHOST=\"$chost\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "CHOST=\"$chost\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "COMMON_FLAGS"; then
              sed -i "s/COMMON_FLAGS=.*/COMMON_FLAGS=\"$cflags\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "COMMON_FLAGS=\"$cflags\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            if cat /mnt/gentoo/etc/portage/make.conf | grep -q "MAKEOPTS"; then
              sed -i "s/MAKEOPTS=.*/MAKEOPTS=\"$mkopts\"/g" /mnt/gentoo/etc/portage/make.conf;
            else
              echo "MAKEOPTS=\"$mkopts\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
            fi

            if [ ! -z "$useflg" ]; then
              if cat /mnt/gentoo/etc/portage/make.conf | grep -q "^USE="; then
                sed -i "s/USE=.*/USE=\"$useflg\"/g" /mnt/gentoo/etc/portage/make.conf
              else
                echo "USE=\"$useflg\"" | tee -a /mnt/gentoo/etc/portage/make.conf;
              fi
            fi

            break;;
          * ) break;;
        esac
      done

      while true; do
        read -p "Select action: [r]econfigure | [e]xit   " ftch
        case $ftch in
          [Rr]* ) break;;
          [Ee]* ) break 2;;
          * ) echo "Invalid input"
        esac
      done;;
    * ) break;;
  esac
done

while true; do
  read -p "Select mirrors [Yn]?   " smrrs
  case $smrrs in
    [Nn]* ) break;;
    * ) mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf; clear; break;;
  esac
done

mkdir -p /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

echo "

#!/bin/bash

rootfstmp=
rootfstyp=
create_fstab() {
  fsv=''
  while true; do
    read -p 'Regenerate /etc/fstab [Yn]?   ' rfst
    case \$rfst in
      [Nn]* ) break;;
      * )
        while true; do
          read -p '
[1] Backup current /etc/fstab
[2] Clean /etc/fstab
[3] Add device
[4] Commit /etc/fstab
[5] Exit

Action:   ' fsta
          case \$fsta in
            1 )
              cp -raf hello /etc/fstab.bup
              echo 'Backup created: /etc/fstab'
              ;;
            2 ) fsv='';;
            3 )
              while true; do
                blkid
                read -p 'Enter device (e.g. /dev/sdXn):   ' td
                case \$td in
                  * )
                    if blkid | grep -q \"\$td: \"; then
                      type=\$(blkid | grep \"\$td\" | head -1 | awk -F ' TYPE=\"' '{print \$2}' | cut -f 1 -d '\"')
                      uuid=\$(blkid | grep \"\$td\" | head -1 | awk -F ' UUID=\"' '{print \$2}' | cut -f 1 -d '\"')
                      if [ \"\$type\" == \"swap\" ]; then

                        fsv+=\"UUID=\$uuid    none    \$type    sw    0 0 \n\"
                        break
                      else
                        pass=2
                        while true; do
                          read -p 'Is this a root partition [yN]?   ' itrp
                          case \$itrp in
                            [Yy]* ) rootfstmp=\"\$type\"; pass=1; break;;
                            * ) pass=2; break;;
                          esac
                        done

                        mountpoint=
                        while true; do
                          read -p 'Enter mountpoint (e.g. /boot/efi)    ' mp
                          case \$mp in
                            * )
                              if [ ! -z \"\$mp\" ]; then
                                mountpoint=\"\$mp\"
                                break
                              else
                                echo 'Mountpoint is required'
                              fi
                              ;;
                          esac
                        done

                        fsv+=\"UUID=\$uuid    \$mountpoint    \$type    rw,noatime    0 \$pass \n\"
                        break
                      fi
                    else
                      break
                    fi
                    ;;
                esac
              done;;
            4 ) rootfstyp=\"\$rootfstmp\"; printf \"\$fsv\" | tee /etc/fstab;;
            5 ) break;;
            * ) echo 'Invalid action';;
          esac
        done;;
    esac
  done
}

execute_additional_commands() {
  while true; do
    read -p \"
You might want to execute commands like:

  yes | sudo etc-update --automode -3
  eselect news read
  emerge --oneshot portage
  emerge --depclean
  emerge @preserved-rebuild

You can execute it here or just enter \"e\" to exit. Only execute commands
you need.

Action: \" cmd
    case \$cmd in
      [Ee] ) break;;
      * ) \$cmd;;
    esac
  done
}

source /etc/profile

emerge-webrsync
execute_additional_commands

emerge --sync
execute_additional_commands

while true; do
  read -p \"Update profile [Yn]?   \" updtp
  case \$updtp in
    [Nn]* ) break;;
    * )
      while true; do
        eselect profile list | grep systemd | grep stable | grep '\[.*\]'
        read -p \"Profile to set:   \" pts
        case \$pts in
          * )
            if [[ \$pts =~ ^[0-9]+$ ]]; then
              if eselect profile list | grep systemd | grep stable | grep -q \"\[\$pts\]\"; then
                eselect profile set \$pts
                echo \"Profile \$pts selected\"
                break;
              else
                echo \"Invalid number\"
              fi
            else
              echo \"Invalid number\";
            fi;;
        esac
      done;;
  esac
done

emerge --ask --verbose --update --deep --newuse @world
execute_additional_commands

while true; do
  read -p \"Set timezone (e.g. America/Chicago)   \" tz
  case \$tz in
    * )
      if [[ \$tz =~ ^[a-zA-Z]+/[a-zA-Z]+$ ]]; then
        if ls /usr/share/zoneinfo/\$tz 2>/dev/null; then
          echo \$tz > /etc/timezone
          ln -sf /usr/share/zoneinfo/\$tz /etc/localtime;
          emerge --config sys-libs/timezone-data
          break;
        else
          echo Timezone doesnt exist
        fi
      else
        echo Invalid input
      fi
  esac
done

while true; do
  read -p \"Actions: [a]ctivate locales | [d]eactivate locales | [g]enerate locales | [e]xit   \" a
  case \$a in
    [Aa] )
      while true; do
        read -p \"Activate locale (e.g. 'en_US.UTF-8 UTF-8') or [e]xit   \" al
        case \$al in
          [Ee] ) break;;
          * )
            sed -i \"s/^#\$al/\$al/g\" /etc/locale.gen
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
    * )
      echo \"LANG=\$l\" | tee /etc/locale.conf
      echo \"LANG=\$l\" | tee /etc/env.d/02locale
      ;;
  esac
done

hwclock --systohc

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
        echo \$hn | tee /etc/hostname
        echo \"
127.0.0.1    localhost
::1          localhost
127.0.1.1    \$hn.localdomain \$hn
\" | tee /etc/hosts;
      fi
  esac
done

systemd-machine-id-setup
env-update && source /etc/profile

emerge sys-kernel/gentoo-sources
emerge sys-kernel/dracut
emerge sys-kernel/genkernel-next
emerge sys-kernel/linux-firmware
emerge sys-apps/pciutils
emerge sys-apps/usbutils

ln -sf /proc/self/mounts /etc/mtab
echo 'add_dracutmodules+=\"usrmount\"' | tee /etc/dracut.conf.d/usrmount.conf

if cat /etc/genkernel.conf | grep 'UDEV='; then
  sed -i 's/#UDEV=/UDEV=/g' /etc/genkernel.conf
  sed -i 's/UDEV=.*/UDEV=\"yes\"/g' /etc/genkernel.conf
else
  echo 'UDEV=\"yes\"' | tee -a /etc/genkernel.conf
fi

create_fstab
while true; do
  read -p \"Auto generate kernel settings [yN]?    \" agks
  case \$agks in
    [Yy]* )
      genkernel all;;
    * )
      while true; do
        read -p \"
Next step is configuring the kernel. Follow the instructions below:

1. Open tty2 terminal (Ctrl + Alt + F2), you can go back here (tty1) by pressing (Ctrl + Alt + F1)
2. If not on chroot, execute: chroot /mnt/gentoo /bin/bash
3. Execute: lspci
4. Take note about the output in lspci. Those devices should be enabled on kernel settings.
5. Execute: lsusb
6. Take note about the output in lsusb. Those devices should be enabled on kernel settings.
7. Execute: genkernel --menuconfig all
8. Go back here in tty1 (Ctrl + Alt + F1) then proceed

Proceed [yN]   \" initk
        case \$initk in
          [Yy]* )
            while true; do
              read -p \"
Enable and disable the following settings under General setup:

  General setup
    [*] Namespaces support
      [*] Network namespace
    [*] Checkpoint/restore support
    [ ] Enable deprecated sysfs...
    [*] Configure standard kernel features
      [*] open by fhandle syscalls
      [*] Enable eventpoll support
      [*] Enable signalfd() system call
      [*] Enable timerfd() system call
    [*] Enable bpf() system call
    [*] Control Group support
      [*] Support for eBPF programs...

Action: [p]roceed | [e]xit   \" gsk
              case \$gsk in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Firmware Drivers:

  Firmware Drivers
    [*] Export DMI identification via sysfs to userspace

Action: [p]roceed | [e]xit   \" fwd
              case \$fwd in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Power management and ACPI options:

  Power management and ACPI options
    [*] Suspend to RAM and standby
    [*] Hibernation
    [*] ACPI Support

Action: [p]roceed | [e]xit   \" mpao
              case \$mpao in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Binary Emulations:

  Binary Emulations
    [*] IA32 Emulation

Action: [p]roceed | [e]xit   \" bie
              case \$bie in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Processor type and features:

  Processor type and features
    [*] Symmetric multi-processing support
    [ ] Machine Check / overheating reporting
    [*] CPU microcode loading support
    [*] <YOUR_CPU> microcode loading support
    [*] MTRR (Memory Type Range Register) support
    [*] Enable seccomp to safely compute untrusted bytecode

Action: [p]roceed | [e]xit   \" ptaf
              case \$ptaf in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Enable block layer:

  [*] Enable the block layer
    [*] Block layer SG support v4

Action: [p]roceed | [e]xit   \" ell
              case \$ell in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Networking support:

  [*] Networking support
    Networking options
      [M] The IPv6 protocol

Action: [p]roceed | [e]xit   \" ns
              case \$ptaf in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable & disable the following settings under Device Drivers:

  Device Drivers
    Generic Driver Options
      [*] Maintain a devtmpfs filesystem to mount at /dev
      [*] Automount devtmpfs at /dev, after the kernel mounted the rootfs
    SCSI device support
      [*] SCSI disk support
    [*] Network device support
      [*] Ethernet driver support
    Graphics support
      [M] /dev/agpgart (AGP Support)
        [M] <YOUR_CHIPSET> support
      [M] Direct Rendering Manager
      [M] <YOU_GPU_FAMILY>
    HID support
      [*] HID bus support
      [*] Generic HID driver
      [*] Battery level reporting for HID devices
      USB HID support
        [M] USB HID transport layer
    [*] USB support
      [M] xHCI HCD (USB 3.0) support
      [M] Generic xHCI driver for platform device
      [M] EHCI HCD (USB 2.0) support
      [M] OHCI HCD (USB 1.1) support

Action: [p]roceed | [e]xit   \" dd
              case \$dd in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under File systems:

  File systems
    [*] Inotify support for userspace
    [M] Kernel automounter version 4 support
    Pseudo filesystems
      [*] /proc file system support
      [*] sysfs file system support
      [*] Tmpfs virtual memory file system support (former shm fs)
      [*] Tmpfs POSIX Access Control Lists
      [*] Tmpfs extended attributes

Action: [p]roceed | [e]xit   \" fs
              case \$fs in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Enable the following settings under Gentoo Linux:

  Gentoo Linux
    Support for init systems...
      [*] OpenRC
      [*] systemd

Action: [p]roceed | [e]xit   \" gl
              case \$gl in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
If using UEFI enable these settings:

  Processor type and features
    [*] EFI runtime service support
    [*] EFI stub support
    [*] EFI mixed-mode support
  Firmware Drivers
    EFI (Extensible Firmware Interface) Support
      [M] EFI Variable Support via sysfs
  [*] Enable the block layer
    Partition Types
      [*] Advanced partition selection
      [*] EFI GUID Partition support

Action: [p]roceed | [e]xit   \" gl
              case \$gl in
                [Pp]* ) break;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done

            while true; do
              read -p \"
Save and exit to generate the customized kernel. Proceed after compilation
Action: [p]roceed | [e]xit   \" ckgp
              case \$ckgp in
                [Pp]* )
                  break 3;;
                [Ee]* ) break 2;;
                * ) echo \"Invalid input\"
              esac
            done;;
          * ) break;;
        esac
      done;;
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

emerge net-misc/dhcpcd
emerge --deselect sys-fs/udev

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
                echo 'GRUB_PLATFORMS=\"efi-64\"' >> /etc/portage/make.conf
                emerge --ask --update --newuse --verbose sys-boot/grub:2
                mount -o remount,rw /sys/firmware/efi/efivars
                grub-install --target=x86_64-efi --efi-directory=\$ed --bootloader-id=GRUB;

                if cat /etc/default/grub | grep '^GRUB_CMDLINE_LINUX='; then
                  sed -i \"s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\\\"init=/lib/systemd/systemd rootfstype=\$rootfstyp\\\"/g\" /etc/default/grub
                else
                  echo \"GRUB_CMDLINE_LINUX=\\\"init=/lib/systemd/systemd rootfstype=\$rootfstyp\\\"\" | tee -a /etc/default/grub
                fi

                grub-mkconfig -o /boot/grub/grub.cfg

                grubdir='gentoo'
                if [ -f \$ed/EFI/gentoo/grubx64.efi ]; then
                  grubdir='gentoo'
                elif [ -f \$ed/EFI/GRUB/grubx64.efi ]; then
                  grubdir='GRUB'
                elif [ -f \$ed/EFI/grub/grubx64.efi ]; then
                  grubdir='grub'
                fi

                mkdir -p \$ed/EFI/BOOT
                cp -a \$ed/EFI/\$grubdir/grubx64.efi \$ed/EFI/BOOT/bootx64.efi

                echo '
bcf boot add 1 fs0:\EFI\BOOT\grubx64.efi \"Fallback Bootloader\"
exit' | tee \$ed/startup.nsh

                echo Installed GRUB in UEFI mode;
                break 2
              else
                echo EFI Directory doesnt exist;
                break
              fi
              ;;
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
              echo 'GRUB_PLATFORMS=\"efi-64\"' >> /etc/portage/make.conf
              emerge --ask --update --newuse --verbose sys-boot/grub:2
              grub-install --target=i386-pc \$td;

              if cat /etc/default/grub | grep '^GRUB_CMDLINE_LINUX='; then
                sed -i \"s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\\\"init=/lib/systemd/systemd rootfstype=\$rootfstyp\\\"/g\" /etc/default/grub
              else
                echo \"GRUB_CMDLINE_LINUX=\\\"init=/lib/systemd/systemd rootfstype=\$rootfstyp\\\"\" | tee -a /etc/default/grub
              fi

              grub-mkconfig -o /boot/grub/grub.cfg
              echo Installed GRUB in LEGACY mode;
              break 2;;
          esac
        done;;
      * ) echo Invalid input;;
    esac
  done
fi

emerge app-admin/sudo
emerge dev-vcs/git app-editors/vim
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
              useradd -m -G users,wheel,audio,video,portage,usb -s /bin/bash \$un
              usermod -g wheel \$un
              passwd \$un;
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




































" | tee /mnt/gentoo/gentoo-install;


echo '

#####################################
#####################################
###                               ###
###  EXECUTE bash gentoo-install  ###
###  UPON ENTERING THE CHROOT     ###
###                               ###
#####################################
#####################################

'

chroot /mnt/gentoo /bin/bash
