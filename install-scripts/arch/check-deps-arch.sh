


os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))
sudo pacman -Syy

check_packages() {
  sudo pacman -S $1 --noconfirm
}

echo "
Packages from the AUR will not be checked
";


while true; do
  read -p "Check packages for script 10 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        acpid
        base-devel
        numlockx
        xdg-user-dirs
        dummy-package-to-cancel-install
      "

      if [ "$os" != "manjaro" ]; then
        check_packages "linux linux-headers linux-lts linux-lts-headers dummy-package-to-cancel-install"
      else
        major=$(uname -r | cut -f 1 -d .);
        minor=$(uname -r | cut -f 2 -d .);
        version=$(echo $major$minor);
        check_packages "linux$version linux$version-headers dummy-package-to-cancel-install"
      fi

      break;;
  esac
done

while true; do
  read -p "Check packages for script 20 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        ttf-dejavu
        xf86-input-keyboard
        xf86-input-libinput
        xf86-input-mouse
        xf86-video-fbdev
        xf86-video-vesa
        xorg-bdftopcf
        xorg-fonts-75dpi
        xorg-fonts-100dpi
        xorg-mkfontdir
        xorg-mkfontscale
        xorg-server
        xorg-xbacklight
        xorg-xdpyinfo
        xorg-xinit
        xorg-xinput
        xorg-xmodmap
        xorg-xprop
        xorg-xrandr
        xorg-xrdb
        dummy-package-to-cancel-install
      "

      break;;
  esac
done

while true; do
  read -p "Check packages for script 25 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        accountsservice
        alsa-utils
        amd-ucode
        arandr
        atool
        base-devel
        broadcom-wl-dkms
        catdoc
        compton
        conky
        dmenu
        docx2txt
        dunst
        feh
        ffmpegthumbnailer
        file
        flashplugin
        gst-libav
        gst-plugins-bad
        gst-plugins-base
        gst-plugins-base-libs
        gst-plugins-good
        gst-plugins-ugly
        gstreamer
        gtk2
        gtk3
        gtk-engine-murrine
        gtk-engines
        i3-gaps
        i3-wm
        i3lock
        i3status
        intel-ucode
        jre-openjdk
        jsoncpp
        lib32-libva-mesa-driver
        lib32-mesa
        lib32-mesa-vdpau
        lib32-nvidia-utils
        lib32-vulkan-icd-loader
        lib32-vulkan-intel
        lib32-vulkan-radeon
        libarchive
        libcaca
        libimagequant
        libmpdclient
        libpulse
        libva-mesa-driver
        libva-vdpau-driver
        libvdpau-va-gl
        lightdm
        lightdm-gtk-greeter
        lightdm-gtk-greeter-settings
        lxappearance
        lynx
        mediainfo
        mesa
        mesa-vdpau
        mpc
        mpd
        mupdf-tools
        nautilus
        ncmpcpp
        neofetch
        network-manager-applet
        networkmanager
        noto-fonts
        nvidia
        nvidia-lts
        nvidia-utils
        odt2txt
        papirus-icon-theme
        pavucontrol
        pepper-flash
        poppler
        pulseaudio
        pygmentize
        python-chardet
        python-pip
        ranger
        rofi
        rxvt-unicode
        scrot
        tar
        transmission-cli
        unrar
        unzip
        vifm
        vulkan-icd-loader
        vulkan-intel
        vulkan-radeon
        w3m
        xf86-video-amdgpu
        xf86-video-ati
        xf86-video-intel
        xorg-xbacklight
        xorg-xinput
        xorg-xrandr
        xorg-xrdb
        xz
        zip
        dummy-package-to-cancel-install
      "

      if [ "$os" != "manjaro" ]; then
        check_packages "linux linux-headers linux-lts linux-lts-headers dummy-package-to-cancel-install"
      else
        major=$(uname -r | cut -f 1 -d .);
        minor=$(uname -r | cut -f 2 -d .);
        version=$(echo $major$minor);
        check_packages "linux$version linux$version-headers dummy-package-to-cancel-install"
      fi

      break;;
  esac
done

while true; do
  read -p "Check packages for script 30 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        bash-completion
        blueman
        bluez
        bluez-cups
        bluez-utils
        cups
        cups-pdf
        curl
        eog
        evince
        exfat-utils
        firefox
        fuse-exfat
        gcc
        geary
        gedit
        gimp
        git
        gnome-calculator
        gnome-calendar
        gnome-keyring
        gparted
        gufw
        httpie
        libreoffice-fresh
        lsof
        make
        nss-mdns
        ntfs-3g
        openssh
        os-prober
        p7zip
        perl
        polkit-gnome
        pulseaudio-bluetooth
        refind-efi
        samba
        simplescreenrecorder
        tmux
        transmission-gtk
        ufw
        vim
        virtualbox
        virtualbox-guest-iso
        virtualbox-host-dkms
        vlc
        wget
        xarchiver
        dummy-package-to-cancel-install
      "

      break;;
  esac
done

