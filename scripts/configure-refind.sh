
outputs="KNAME,FSTYPE,TYPE,SIZE,UUID,LABEL,MOUNTPOINT"
outuuid="UUID,KNAME,FSTYPE,TYPE,SIZE,LABEL,MOUNTPOINT"
entryname=
icon=
volume=
loader=
initrd=
options=

generate_menu_entry() {
  echo "
menuentry \"$entryname\" {
    icon     $icon
    volume   \"$volume\"
    loader   $loader" | sudo tee -a /boot/efi/EFI/refind/refind.conf

  if [ ! -z "$initrd" ]; then
    echo "    initrd   $initrd" | sudo tee -a /boot/efi/EFI/refind/refind.conf
  fi

  if [ ! -z "$options" ]; then
    echo "    options \"$options\"" | sudo tee -a /boot/efi/EFI/refind/refind.conf
  fi

  echo "} " | sudo tee -a /boot/efi/EFI/refind/refind.conf
  # echo "} " | sudo tee -a $(pwd)/refind.conf
}

declare_entryname() {
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
}

declare_icon() {
  while true; do
    read -p "Enter OS/Distro (e.g. arch, fedora, mac):   " tdistro
    case $tdistro in
      * )
        if [ -z $tdistro ]; then
          echo "Distro/OS input is required... "
        else
          distro=$(echo -n "$tdistro" | sed -e 's/\(.*\)/\L\1/')
          break
        fi;;
    esac
  done

  themeStr='include themes/rEFInd-minimal/theme.conf'
  if sudo cat /boot/efi/EFI/refind/refind.conf.bup | grep -q "$themeStr"; then
    if [ -f "/boot/efi/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png" ]; then
      icon="/EFI/refind/themes/rEFInd-minimal/icons/os_$distro.png"
    else
      icon="/EFI/refind/themes/rEFInd-minimal/icons/os_linux.png"
    fi
  else
    if [ -f "/boot/efi/EFI/refind/icons/os_$distro.png" ]; then
      icon="/EFI/refind/icons/os_$distro.png"
    else
      icon="/EFI/refind/icons/os_linux.png"
    fi
  fi
}

declare_volume(){
  volume=$(sudo blkid | grep $1 | head -1 | awk -F 'PARTUUID="' '{print $2}' | awk -F '"' '{ print $1 }')

  # if sudo blkid | grep $1 | head -1 | grep -q 'PARTLABEL'; then
  #   volume=$(sudo blkid | grep $1 | head -1 | awk -F 'PARTUUID="' '{print $2}' | awk -F '"' '{ print $1 }')
  # else
  #   while true; do
  #     lsblk -o NAME,TYPE,SIZE,MODEL | grep -v 'part'
  #     echo "This partition has no name. Enter a name to proceed."
  #     read -p "Target partition (e.g. sdX)   " target
  #     case $target in
  #       * )
  #         if lsblk -o NAME,TYPE,SIZE,MODEL | grep -v 'part' | grep -q $target; then
  #           while true; do
  #             sudo parted -l
  #             read -p "Partition number   " number
  #             case $number in
  #               * )
  #                 if lsblk -o KNAME | grep -v 'part' | grep -q "/dev/$target$number "; then
  #                   while true; do
  #                     read -p "Partition name   " name
  #                     case $name in
  #                       * )
  #                         parted $target name $name $number
  #                         volume="$name"
  #                         break 3;;
  #                     esac
  #                   done
  #                 else
  #                   echo "Invalid partition number..."
  #                 fi;;
  #             esac
  #           done
  #         else
  #           echo "Invalid partition..."
  #         fi;;
  #     esac
  #   done
  # fi
}

declare_loader_initrd() {
  loader=$(echo -n /boot/$(ls "$1" | grep -e "vmlinuz" -e "genkernel" | grep -v -e 'rescue' -e 'fallback' | tail -1))
  initrd=$(echo -n /boot/$(ls "$1" | grep 'init' | grep -v -e 'rescue' -e 'fallback' | tail -1))
}

add_kernel_params(){
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
                swapuuid=$(lsblk -i -o $outuuid | grep 'part' | grep 'swap' | grep "$sprtn "  | head -1 | cut -f 1 -d ' ')
                options+=" resume=$swapuuid"
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
                options+=" $akparamsval"
              fi
              break;;
          esac
        done;;
      * ) break;;
    esac
  done
}

while true; do
  read -p "Refind Configuration

NOTES:

* Make sure you execute this script in your main distribution.
* This script assumes you are using UEFI mounted on /boo/efi
* This script assumes refind config is located on:
    /boot/efi/EFI/refind/refind.conf
* MacOS volumes cannot be fetch in linux. Execute the command
  below in macOS to get the volume name:
    diskutil list
    diskutil info </dev/diskN>

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
* MacOS volumes cannot be fetch in linux. Execute the command
  below in macOS to get the volume name:
    diskutil list
    diskutil info </dev/diskN>

[1] Add main menuentry
[2] Add other menuentry
[3] Add macOS menuentry

[0] Done

Choose action   " blcstmztn
              case $blcstmztn in
                [1] )
                  entryname=
                  icon=
                  volume=
                  loader=
                  initrd=
                  options=

                  declare_entryname
                  declare_icon
                  declare_loader_initrd '/boot'

                  root=$(mount -v | grep 'on / ' | cut -f 1 -d ' ')
                  declare_volume "$root"

                  rootuuid=$(sudo blkid | grep $root | head -1 | cut -f 2 -d ' ')
                  if [[ $rootuuid == *"LABEL"* ]]; then
                    rootuuid=$(sudo blkid | grep $root | cut -f 3 -d ' ')
                  fi

                  if [[ $rootuuid != *"UUID"* ]]; then
                    rootuuid=$root
                  fi

                  rootuuid=$(echo $rootuuid | sed 's/\"//g')
                  options+="rw root=$rootuuid"

                  add_kernel_params
                  generate_menu_entry;;
                [2] )
                  entryname=
                  icon=
                  volume=
                  loader=
                  initrd=
                  options=

                  while true; do
                    lsblk -i -o $outputs | grep 'part' | grep 'ext4' | grep -v -e 'swap' -e '/'
                    read -p "Enter partition (e.g. sdXn)   " prttn
                    case $prttn in
                      * )
                        if lsblk -i -o $outputs | grep 'part' | grep 'ext4' | grep -v -e 'swap' | grep -q "$prttn "; then
                          sudo mkdir -p /mnt-refind
                          echo "Mounting /dev/$prttn"
                          sudo mount "/dev/$prttn" "/mnt-refind"

                          declare_entryname
                          declare_volume "/dev/$prttn"
                          declare_icon
                          declare_loader_initrd '/mnt-refind/boot'

                          uuid=$(lsblk -i -o $outuuid | grep 'part' | grep 'ext4' | grep -v -e 'swap' | grep "$prttn " 2> /dev/null | head -1 | cut -f 1 -d ' ')
                          options+="rw root=UUID=$uuid"

                          add_kernel_params
                          generate_menu_entry

                          echo "Unmounting /dev/$prttn"
                          sudo umount "/dev/$prttn"
                          break
                        else
                          echo "$prttn not found..."
                        fi;;
                    esac
                  done;;
                [3] )
                  entryname=
                  icon=
                  volume=
                  loader=
                  initrd=
                  options=

                  declare_entryname
                  declare_icon

                  while true; do
                    read -p 'Enter volume name:   ' vname
                    case $vname in
                      * )
                        if [ ! -z "$vname" ]; then
                          volume="$vname"
                          break
                        else
                          echo "Volume name is required for macOS..."
                        fi;;
                    esac
                  done

                  loader='\System\Library\CoreServices\boot.efi'

                  generate_menu_entry
                  ;;
                [0] )

                  scanfor='manual,external'
                  while true; do
                    read -p 'Append autoscan results [yN]?   ' aas
                    case $aas in
                      [Yy]* )
                        scanfor+=',internal'
                        break;;
                      * ) break;;
                    esac
                  done

                  echo "scanfor $scanfor" | sudo tee -a /boot/efi/EFI/refind/refind.conf
                  # echo "scanfor $scanfor" | sudo tee -a $(pwd)/refind.conf

                  echo "timeout 10" | sudo tee -a /boot/efi/EFI/refind/refind.conf
                  # echo "timeout 10" | sudo tee -a $(pwd)/refind.conf

                  themeStr='include themes/rEFInd-minimal/theme.conf'
                  if sudo cat /boot/efi/EFI/refind/refind.conf.bup | grep -q "$themeStr"; then
                    echo "$themeStr" | sudo tee -a /boot/efi/EFI/refind/refind.conf
                    # echo "$themeStr" | sudo tee -a $(pwd)/refind.conf
                  fi

                  echo "Customization done..."
                  break 3;;
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

