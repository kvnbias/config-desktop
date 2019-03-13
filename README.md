# CONFIG-DESKTOP

Current default configs and scripts for my desktop environments.

## Quick start (Arch)


```sh
# wget -O arch-install https://git.io/fjeJ9
# bash arch-install
```

## Post install (Arch)

```sh
$ bash 10\ -\ arch-post-install.sh
$ bash 20\ -\ arch-post-install-xorg.sh
$ bash 25\ -\ arch-ricing-xorg-i3.sh
...
```

## Notes

* For multiboot it is recommended to only install a bootloader in your main distro.
* For debian-based distros using ubiquity installer you can remove the bootloader from the installation by executing `ubiquity -b` on the terminal.
* For RHEL-based distros using anaconda installer you can remove bootloader on full disk summary.
* Use `os-prober` to detect other OS.

## As of 03/15/2019

##### Arch scripts are tested on:
* Arch
* Manjaro (18)
* Manjaro Arch (18 - Minimal CLI)
##### RHEL scripts are tested on
* Fedora (Everything 29 - Minimal, Workstation 29)
