# CONFIG-DESKTOP

Current default configs and scripts for my desktop environments.

## Notes
* Desktop Environment ready distros (Ubuntu, Fedora Workstation etc) should start with scripts #25.
* Minimal Installs (CLI only install) should start with scripts #10
* For multiboot it is recommended to only install a bootloader in your main distro.
* For debian-based distros using ubiquity installer you can remove the bootloader from the installation by executing `ubiquity -b` on the terminal.
* For RHEL-based distros using anaconda installer you can remove bootloader on full disk summary.
* If GRUB is installed, use `os-prober` to detect other OS.

## Quick start (Arch)


```sh
# wget -O arch-install https://git.io/fjfJ9
# bash arch-install
```

## Post install (Arch)

```sh
$ bash 10\ -\ arch-post-install.sh
$ bash 20\ -\ arch-post-install-xorg.sh
$ bash 25\ -\ arch-ricing-xorg-i3.sh
...
```

## As of 03/15/2019

##### Arch scripts are tested on:
* Arch
* Manjaro (Desktop 18, Architect 18 Minimal)
##### RHEL scripts are tested on
* Fedora (Everything 29 - Minimal, Workstation 29)
##### Debian scripts are tested on
* Debian (Desktop 10, Minimal 10)
* Elementary (5.0)
* Ubuntu (18.04 LTS)
