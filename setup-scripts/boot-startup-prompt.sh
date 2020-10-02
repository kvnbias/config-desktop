
#!/bin/bash

if [ -d /sys/firmware/efi/efivars ] && sudo test -d /boot/efi/EFI && sudo test ! -f /boot/efi/startup.nsh; then
  sudo mkdir -p /boot/efi/EFI/boot
  if [ -d "/boot/efi/EFI/refind" ]; then
    sudo cp -a /boot/efi/EFI/refind/refind_x64.efi /boot/efi/EFI/boot/bootx64.efi
  elif [ -d "/boot/efi/EFI/grub" ]; then
    sudo cp -a /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  elif [ -d "/boot/efi/EFI/GRUB" ]; then
    sudo cp -a /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  else
    os=$(echo $1 | cut -d- -f1 | head -1)
    if [ "$os" == "pop" ]; then
      popDir=$(sudo ls /boot/efi/EFI | grep Pop)
      sudo cp -a /boot/efi/EFI/$popDir/vmlinuz.efi /boot/efi/EFI/boot/bootx64.efi
    else
      sudo cp -a /boot/efi/EFI/$os/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
    fi
  fi

  echo "bcf boot add 1 fs0:\\EFI\\boot\\bootx64.efi \"Fallback Bootloader\"
exit" | sudo tee /boot/efi/startup.nsh
fi
