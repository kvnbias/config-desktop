
generate_menu_entry() {
  echo "
menuentry \"$1\" {
    icon     $2
    volume   $3
    loader   $4
    initrd   $5
    options  $6
}
" | sudo tee -a /boot/efi/EFI/refind/refind.conf
# " | sudo tee -a $(pwd)/refind.conf
}

while true; do
  read -p "Refind Configuration

NOTES:

* Make sure you execute this script in your main distribution.
* This script assumes you are using UEFI mounted on /boo/efi
* This script assumes refind config is located on:
    /boot/efi/EFI/refind/refind.conf

[1] Customize
[2] Restore Defaults
[e] Do nothing

Default=e
Action:   " crfnd
  case $crfnd in
    [1] )
      while true; do
        read -p "
Point of no return. Your refind config will be on a clean slate, If you wish to
cancel this operation. Re-run this script then choose \"Restore Defaults\"

Do you wish to proceed [yN]?   " prcd
        case $prcd in
          [Yy]* )
            if [ -f /boot/efi/EFI/refind/refind.conf.bup ]; then
              echo "Backup already exists. Proceeding operation."
            else
              sudo cp -a /boot/efi/EFI/refind/refind.conf /boot/efi/EFI/refind/refind.conf.bup
            fi

            echo "" | sudo tee /boot/efi/EFI/refind/refind.conf
            # echo "" | sudo tee $(pwd)/refind.conf

            while true; do
              read -p "
Bootloader Customization

NOTES
* The menuentry of this distro will be appended automatically in \"Done\" action.

[1] Add main menuentry
[2] Add other menuentry
[3] Done

Default=2
Choose action   " blcstmztn
              case $blcstmztn in
                [1] )
                  outputs="KNAME,FSTYPE,TYPE,SIZE,UUID,LABEL,MOUNTPOINT"
                  distro=$(echo -n $(cat /etc/*-release | grep ^ID= | sed -e "s/ID=//"))
                  themeStr='include themes/rEFInd-minimal/theme.conf'

                  entryname=
                  while true; do
                    read -p "Enter this OS's entryname:   " mosen
                    case $mosen in
                      * )
                        if [ -z "$mosen" ]; then
                          echo "Entry name is required..."
                        else
                          entryname=$mosen
                          break
                        fi
                        ;;
                    esac
                  done

                  if sudo cat /boot/efi/EFI/refind/refind.conf.bup | grep -q "$themeStr"; then
                    if [ -f "/boot/efi/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png" ]; then
                      icpath="/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png"
                    else
                      icpath="/EFI/refind/themes/rEFInd-minimal/icons/os_linux.png"
                    fi
                  else
                    if [ -f "/boot/efi/EFI/refind/icons/os_$distro.png" ]; then
                      icpath="/EFI/refind/icons/os_$distro.png"
                    else
                      icpath="/EFI/refind/icons/os_linux.png"
                    fi
                  fi

                  loader=$(echo -n $(ls "/boot" | grep 'vmlinuz' | grep -v -e 'rescue' -e 'fallback' | tail -1))
                  initrd=$(echo -n $(ls "/boot" | grep 'init' | grep -v -e 'rescue' -e 'fallback' | tail -1))

                  kernelparams=

                  root=$(mount -v | grep 'on / ' | cut -f 1 -d ' ')
                  rootuuid=$(sudo blkid | grep $root | head -1 | cut -f 2 -d ' ')
                  if [[ $rootuuid == *"LABEL"* ]]; then
                    rootuuid=$(sudo blkid | grep $root | cut -f 3 -d ' ')
                  fi

                  if [[ $rootuuid != *"UUID"* ]]; then
                    rootuuid=$root
                  else
                    rootuuid=$(echo $root | cut -f 2 -d '=')
                  fi

                  boot=$(mount -v | grep 'on /boot/efi ' | cut -f 1 -d ' ')
                  bootuuid=$(sudo blkid | grep $boot | head -1 | cut -f 2 -d ' ')
                  if [[ $bootuuid == *"LABEL"* ]]; then
                    bootuuid=$(sudo blkid | grep $boot | cut -f 3 -d ' ')
                  fi

                  if [[ $bootuuid != *"UUID"* ]]; then
                    bootuuid=$boot
                  else
                    bootuuid=$(echo $bootuuid | cut -f 2 -d '=' )
                  fi

                  while true;do
                    read -p "Add hibernation on kernel parameters [yN]?   " ahbrnt
                    case $ahbrnt in
                      [Yy]* )
                        while true; do
                          lsblk -i -o $outputs | grep 'part' | grep 'swap'
                          read -p "Choose swap partition (sdXn) or [e]xit   " sprtn
                          case $sprtn in
                            [Ee]* ) break;;
                            * )
                              if lsblk -i -o $outputs | grep 'part' | grep 'swap' | grep -q "$sprtn "; then
                                swapuuid=$(lsblk -i -o $outputs | grep 'part' | grep 'swap' | grep "$sprtn "  | head -1 | cut -f 11 -d ' ')
                                kernelparams+="resume=$swapuuid"
                                echo "'$swapuuid' added..."
                                break 2
                              else
                                echo "Swap partition doesn't exists..."
                              fi;;
                          esac
                        done;;
                      * ) break;;
                    esac
                  done

                  rootuuid=$(echo $rootuuid | sed 's/\"//g')
                  kernelparams+=" root=UUID=$rootuuid rw"

                  while true; do
                    read -p "Do you want to add kernel params (for apparmor, selinux etc) [yN]?   " akparams
                    case $akparams in
                      [Yy]* )
                        while true; do
                          read -p "Enter kernel params. Use <space> as delimiter (e.g. 'security=selinux selinux=1 quiet')   " akparamsval
                          case $akparamsval in
                            * )
                              if [ ! -z "$akparamsval" ]; then
                                echo "$akparamsval added."
                                kernelparams+=" $akparamsval"
                              fi
                              break;;
                          esac
                        done;;
                      * ) break;;
                    esac
                  done

                  generate_menu_entry "$entryname" "$icpath" "$bootuuid" "/boot/$loader" "/boot/$initrd" "\"$kernelparams\""
                  break;;
                [2] )
                  outputs="KNAME,FSTYPE,TYPE,SIZE,UUID,LABEL,MOUNTPOINT"
                  while true; do
                    lsblk -i -o $outputs | grep 'part' | grep 'ext4' | grep -v -e 'swap' -e '/'
                    read -p "Enter partition (e.g. sdXn)   " prttn
                    case $prttn in
                      * )
                        if lsblk -i -o $outputs | grep 'part' | grep 'ext4' | grep -v -e 'swap' | grep -q "$prttn "; then
                          sudo mkdir -p /mnt-refind
                          echo "Mounting /dev/$prttn"
                          sudo mount "/dev/$prttn" "/mnt-refind"

                          entryname="Entry $prttn"
                          while true; do
                            read -p "Enter name of this entry:   " ename
                            case $ename in
                              *)
                                if [ ! -z "$ename" ]; then
                                  entryname="$ename"
                                  break
                                else
                                  echo "Entry name is required..."
                                fi;;
                            esac
                          done

                          icpath="\\EFI\\refind\\icons\\os_linux.png"
                          osname="Linux"
                          while true; do
                            read -p "Enter name of the distro:   " dname
                            case $dname in
                              * )
                                distro=$(echo -n "$dname" | sed -e 's/\(.*\)/\L\1/')
                                themeStr='include themes/rEFInd-minimal/theme.conf'
                                if sudo cat /boot/efi/EFI/refind/refind.conf.bup | grep -q "$themeStr"; then
                                  if [ -f "/boot/efi/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png" ]; then
                                    icpath="/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png"
                                  else
                                    icpath="/EFI/refind/themes/rEFInd-minimal/icons/os_linux.png"
                                  fi
                                  break
                                else
                                  if [ -f "/boot/efi/EFI/refind/icons/os_$distro.png" ]; then
                                    icpath="/EFI/refind/icons/os_$distro.png"
                                  else
                                    icpath="/EFI/refind/icons/os_linux.png"
                                  fi
                                  break
                                fi;;
                            esac
                          done

                          loader=$(echo -n $(ls "/mnt-refind/boot" | grep 'vmlinuz' | grep -v -e 'rescue' -e 'fallback' | tail -1))
                          initrd=$(echo -n $(ls "/mnt-refind/boot" | grep 'init' | grep -v -e 'rescue' -e 'fallback' | tail -1))

                          kernelparams=
                          uuid=$(lsblk -i -o $outputs | grep 'part' | grep 'ext4' | grep -v -e 'swap' | grep "$prttn " 2> /dev/null | head -1 | cut -f 11 -d ' ')

                          while true;do
                            read -p "Add hibernation on kernel parameters [yN]?   " ahbrnt
                            case $ahbrnt in
                              [Yy]* )
                                while true; do
                                  lsblk -i -o $outputs | grep 'part' | grep 'swap'
                                  read -p "Choose swap partition (sdXn) or [e]xit   " sprtn
                                  case $sprtn in
                                    [Ee]* ) break;;
                                    * )
                                      if lsblk -i -o $outputs | grep 'part' | grep 'swap' | grep -q "$sprtn "; then
                                        swapuuid=$(lsblk -i -o $outputs | grep 'part' | grep 'swap' | grep "$sprtn "  | cut -f 11 -d ' ')
                                        kernelparams+="resume=$swapuuid"
                                        echo "$swapuuid added..."
                                        break 2
                                      else
                                        echo "Swap partition doesn't exists..."
                                      fi;;
                                  esac
                                done;;
                              * ) break;;
                            esac
                          done

                          kernelparams+=" root=UUID=$uuid rw"

                          while true; do
                            read -p "Do you want to add kernel params (for apparmor, selinux etc) [yN]?   " akparams
                            case $akparams in
                              [Yy]* )
                                while true; do
                                  read -p "Enter kernel params. Use <space> as delimiter (e.g. 'security=selinux selinux=1 quiet')   " akparamsval
                                  case $akparamsval in
                                    * )
                                      if [ ! -z "$akparamsval" ]; then
                                        echo "'$akparamsval' added"
                                        kernelparams+=" $akparamsval"
                                      fi
                                      break;;
                                  esac
                                done;;
                              * ) break;;
                            esac
                          done

                          generate_menu_entry "$entryname" "$icpath" "$uuid" "/boot/$loader" "/boot/$initrd" "\"$kernelparams\""

                          echo "Unmounting /dev/$prttn"
                          sudo umount "/dev/$prttn"
                          break
                        else
                          echo "$prttn not found..."
                        fi
                        ;;
                    esac
                  done;;
                [3] )
                  themeStr='include themes/rEFInd-minimal/theme.conf'
                  echo "timeout 10" | sudo tee -a /boot/efi/EFI/refind/refind.conf
                  # echo "timeout 10" | sudo tee -a $(pwd)/refind.conf

                  if sudo cat /boot/efi/EFI/refind/refind.conf.bup | grep -q "$themeStr"; then
                    echo "$themeStr" | sudo tee -a /boot/efi/EFI/refind/refind.conf
                    # echo "$themeStr" | sudo tee -a $(pwd)/refind.conf
                  fi

                  echo "Customization done..."
                  break 2;;
                * ) echo "Invalid input.";;
              esac
            done;;
          * ) break;;
        esac
      done;;
    [2] )
      if [ -f /boot/efi/EFI/refind/refind.conf.bup ]; then
        echo Restored
        sudo cp -raf /boot/efi/EFI/refind/refind.conf /boot/efi/EFI/refind/refind.conf.prev
        sudo cp -raf /boot/efi/EFI/refind/refind.conf.bup /boot/efi/EFI/refind/refind.conf
      else
        echo "
Backup configuration not found. Either your rEFInd config is untouched or the
backup file is deleted.
"
      fi

      break;;
    * ) break;;
  esac
done

