
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))

if [ "$1" = "" ];then
  fedver=$(rpm -E %$os)
else
  fedver=$1
fi

if [ ! -f /usr/bin/dnf ]; then
  sudo yum install -y dnf
fi

sudo dnf update

check_packages() {
  output=$(sudo dnf install --assumeno $1 --releasever=$fedver 2> /dev/null | grep 'No match for argument')
  echo $output | sed -e 's/No/\nNo/g'
}

while true; do
  read -p "Check packages for script 10 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )

      if [ "$os" = "fedora" ]; then
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
      else
        sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
      fi
      sudo dnf update

      check_packages "
        acpid
        autoconf
        automake
        bzip2
        cmake
        dkms
        gcc
        gcc-c++
        kernel-devel
        kernel-headers
        make
        numlockx
        pciutils
        pkgconfig
        usbutils
        xdg-user-dirs
      "
      break;;
  esac
done

while true; do
  read -p "Check packages for script 20 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )

      if [ "$os" = "fedora" ]; then
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
      else
        sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
      fi
      sudo dnf update

      check_packages "
        libinput
        xbacklight
        xorg-x11-drv-fbdev
        xorg-x11-drv-libinput
        xorg-x11-drv-vesa
        xorg-x11-font-utils
        xorg-x11-fonts-75dpi
        xorg-x11-fonts-100dpi
        xorg-x11-server-utils
        xorg-x11-server-Xorg
        xorg-x11-utils
        xorg-x11-xinit
      "

      break;;
  esac
done

while true; do
  read -p "Check packages for script 25 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )

      if [ "$os" = "fedora" ]; then
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedver.noarch.rpm
      else
        sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$fedver.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$fedver.noarch.rpm
      fi
      sudo dnf install -y http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
      sudo dnf update

      check_packages "
        accountsservice
        akmod-nvidia
        alsa-lib
        alsa-lib-devel
        alsa-utils
        arandr
        at
        atool
        autoconf
        automake
        breeze-cursor-theme
        broadcom-wl
        bzip2
        cairo
        cairo-devel
        catdoc
        checkpolicy
        cmake
        compton
        conky
        curl
        dkms
        dmenu
        dnf-plugin-system-upgrade
        dunst
        feh
        ffmpegthumbnailer
        file
        flash-player-ppapi
        flash-plugin
        gcc
        gcc-c++
        gedit
        git
        glib2-devel
        google-noto-fonts-common
        google-noto-sans-fonts
        gstreamer1
        gstreamer1-libav
        gstreamer1-plugins-bad-free
        gstreamer1-plugins-bad-free-extras
        gstreamer1-plugins-bad-freeworld
        gstreamer1-plugins-bad-nonfree
        gstreamer1-plugins-base
        gstreamer1-plugins-base-tools
        gstreamer1-plugins-good
        gstreamer1-plugins-good-extras
        gstreamer1-plugins-good-gtk
        gstreamer1-plugins-ugly-free
        gstreamer1-vaapi
        gtk2
        gtk2-engines
        gtk3
        gtk3-devel
        gtk-murrine-engine
        httpie
        i3
        i3lock
        i3status
        java-openjdk
        jsoncpp
        jsoncpp-devel
        kernel-devel
        kmod-wl
        libarchive
        libcaca
        libcurl-devel
        libev
        libev-devel
        libjpeg-devel
        libjpeg-turbo
        libjpeg-turbo-devel
        libmpdclient
        libmpdclient-devel
        libnl3
        libnl3-devel
        libnotify-devel
        libva-vdpau-driver
        libX11-devel
        libxcb
        libxcb-devel
        libXext-devel
        libXinerama-devel
        libxkbcommon
        libxkbcommon-devel
        libxkbcommon-x11
        libxkbcommon-x11-devel
        libXrandr-devel
        lightdm-gtk
        lightdm-gtk-greeter-settings
        lsof
        lxappearance
        lynx
        make
        mediainfo
        mesa-dri-drivers
        mesa-filesystem
        mesa-libd3d
        mesa-libEGL
        mesa-libgbm
        mesa-libGL
        mesa-libglapi
        mesa-libGLES
        mesa-libGLU
        mesa-libGLw
        mesa-libOpenCL
        mesa-libOSMesa
        mesa-libxatracker
        mesa-vdpau-drivers
        mesa-vulkan-drivers
        mpc
        mpd
        mupdf
        nautilus
        ncmpcpp
        neofetch
        network-manager-applet
        NetworkManager
        NetworkManager-wifi
        notification-daemon
        nvidia-xconfig
        odt2txt
        pam-devel
        pango
        pango-devel
        papirus-icon-theme
        pavucontrol
        pcre-devel
        perl
        pkgconf
        pkgconfig
        policycoreutils-python-utils
        poppler-utils
        pulseaudio
        pulseaudio-libs
        pulseaudio-libs-devel
        pulseaudio-utils
        python
        python2
        python3-chardet
        python3-devel
        python3-pip
        python3-pygments
        ranger
        rofi
        rxvt-unicode-256color-ml
        scrot
        startup-notification
        startup-notification-devel
        tar
        tmux
        transmission-cli
        transmission-common
        unrar
        unzip
        vifm
        vim-enhanced
        vim-minimal
        vulkan-loader
        vulkan-tools
        w3m
        wget
        wireless-tools
        wireless-tools-devel
        xbacklight
        xcb-proto
        xcb-util-cursor
        xcb-util-cursor-devel
        xcb-util-devel
        xcb-util-image
        xcb-util-image-devel
        xcb-util-keysyms
        xcb-util-keysyms-devel
        xcb-util-wm
        xcb-util-wm-devel
        xcb-util-xrm
        xcb-util-xrm-devel
        xorg-x11-drv-amdgpu
        xorg-x11-drv-ati
        xorg-x11-drv-intel
        xorg-x11-drv-nvidia
        xorg-x11-server-utils
        xz-libs
        yajl
        yajl-devel
        zip
        zlib-devel
      "

      break;;
  esac
done

while true; do
  read -p "Check packages for script 30 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      sudo dnf install -y wget
      if [ "$os" = "fedora" ]; then
        wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
      else
        wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
      fi

      sudo mv virtualbox.repo /etc/yum.repos.d/virtualbox.repo
      sudo dnf update

      check_packages "
        bash-completion
        binutils
        blueman
        bluez
        bluez-cups
        bzip2
        bzip2-devel
        cmake
        cups
        cups-pdf
        curl
        dkms
        eog
        evince
        exfat-utils
        firefox
        fuse
        fuse-devel
        fuse-exfat
        gamin
        gcc
        gcc-c++
        geary
        gedit
        gimp
        git
        glibc-devel
        glibc-headers
        gnome-calculator
        gnome-calendar
        gnome-keyring
        gparted
        httpie
        kernel-devel
        kernel-headers
        libattr
        libattr-devel
        libgomp
        libreoffice
        libxkbcommon
        lsof
        make
        mupdf
        nss-mdns
        ntfs-3g
        os-prober
        p7zip
        patch
        perl
        polkit-gnome
        pulseaudio-module-bluetooth
        qt5-qtx11extras
        samba
        simplescreenrecorder
        timeshift
        tmux
        transmission-gtk
        ufw
        vim-enhanced
        VirtualBox-6.0
        virtualbox-guest-additions
        vlc
        wget
        xarchiver
        zlib
        zlib-devel
      "

      break;;
  esac
done
