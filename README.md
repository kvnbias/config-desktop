# CONFIG-DESKTOP

Current default configs and scripts for my desktop environments.

## Quick start

Arch:
```sh
# wget -O arch-install https://git.io/fjn5k
# bash arch-install
```
Gentoo:
```sh
# wget -O gentoo-install https://git.io/fjZlN
# bash gentoo-install
```

## Post install (Arch)

```sh
$ git clone --recurse-submodules https://github.com/kvnbai/config-desktop
$ cd config-desktop/install-scripts/arch
$ bash 10-arch-post-install.sh
$ bash 20-arch-post-install-xorg.sh
...
```

## Notes
* Desktop Environment ready distros (Ubuntu, Fedora Workstation etc) can start with scripts #20.
* Minimal Installs (CLI only install) should start with scripts #10
* For multiboot it is recommended to only install a bootloader in your main distro.
* For debian-based distros using ubiquity installer you can remove the bootloader from the installation by executing `ubiquity -b` on the terminal.
* For RHEL-based distros using anaconda installer you can remove bootloader on full disk summary.
* If GRUB is installed, use `os-prober` to detect other OS.

## Why some packages are compiled from source?
Some packages doesn't exist in the main REPO. If the package exist on community maintained repos, there is a chance that the package is unmaintaned, failing builds, or outdated. I will only include packages from community repos if it is maintained by the authors/contributors of the software. As of now, AUR is the only community maintained repo that I trust.

## As of 05/08/2019
##### Tested in the following distros:
* Arch
* Manjaro
* Fedora 29 & 30
* Debian (Buster)
* Elementary 5
* Ubuntu 18.04, 18.10, 19.10
* Pop!_OS 19.04
* openSUSE Tumbleweed
* Gentoo

### Wallpapers
**I do not own any image in this repository. Since some images have been edited and several artists prefer to not repost their work, the images is moved to a private repository and replaced with a `404` wallpaper. You can check their works instead:**

* [jenn.designs](https://www.instagram.com/jenn.designs/) / [nahamut](https://www.instagram.com/nahamut/)
* [23i2ko](https://www.instagram.com/23i2ko/)
* [hage_2013](https://twitter.com/hage_2013/)
* [BrandonMeier](https://www.behance.net/BrandonMeier)
* [dastardlyapparel](https://www.instagram.com/dastardlyapparel/)
* [gelsgels](https://www.deviantart.com/gelsgels/)
