# CONFIG-DESKTOP

Current default configs and scripts for my desktop environments.

## Quick start (Arch)


```sh
# wget -O arch-install https://git.io/fjfJ9
# bash arch-install
```

## Post install (Arch)

```sh
$ git clone https://github.com/kvnbai/config-desktop
$ cd config-desktop
$ bash 10\ -\ arch-post-install.sh
$ bash 20\ -\ arch-post-install-xorg.sh
$ bash 25\ -\ arch-ricing-xorg-i3.sh
...
```

## Notes
* Desktop Environment ready distros (Ubuntu, Fedora Workstation etc) should start with scripts #25.
* Minimal Installs (CLI only install) should start with scripts #10
* For multiboot it is recommended to only install a bootloader in your main distro.
* For debian-based distros using ubiquity installer you can remove the bootloader from the installation by executing `ubiquity -b` on the terminal.
* For RHEL-based distros using anaconda installer you can remove bootloader on full disk summary.
* If GRUB is installed, use `os-prober` to detect other OS.

## As of 04/06/2019

##### Arch scripts are tested on:
* Arch
* Manjaro 18
##### RHEL scripts are tested on
* Fedora 29
##### Debian scripts are tested on
* Debian 10
* Elementary 5
* Ubuntu (18.04 LTS, 18.10)

### Wallpapers
**I do not own any image in this repository. Since some images have been edited and several artists prefer to not repost their work, the images is moved to a private repository and replaced with a `404` wallpaper. You can check their works instead:**

* [jenn.designs](https://www.instagram.com/jenn.designs/) / [nahamut](https://www.instagram.com/nahamut/)
* [23i2ko](https://www.instagram.com/23i2ko/)
* [hage_2013](https://twitter.com/hage_2013/)
* [BrandonMeier](https://www.behance.net/BrandonMeier)
* [dastardlyapparel](https://www.instagram.com/dastardlyapparel/)


