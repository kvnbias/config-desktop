

DIR="$(cd "$( dirname "$0" )" && pwd)"
os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed -e 's/"//g'))
sudo zypper -n update

check_packages() {
  sudo zypper install --no-recommends $1 | grep --color=always 'not found'
}

while true; do
  read -p "Check packages for script 10 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        acpid
        kernel-devel
        numlockx
        pciutils
        xdg-user-dirs
        dummy-package-to-cancel-install
      "
      break;;
  esac
done

while true; do
  read -p "Check packages for script 20 [Yn]?   " c10
  case $c10 in
    [n]* ) break;;
    * )
      check_packages "
        bdftopcf
        libinput10
        mkfontscale
        xbacklight
        xdpyinfo
        xf86-video-fbdev
        xf86-video-vesa
        xinit
        xinput
        xmodmap
        xorg-x11-fonts
        xorg-x11-server
        xprop
        xrandr
        xrdb

        accountsservice
        alsa
        alsa-devel
        alsa-utils
        at
        atool
        autoconf
        automake
        breeze5-cursors
        bzip2
        cairo-devel
        cmake
        compton
        conky
        curl
        dbus-1-x11
        dkms
        dmenu
        dunst
        feh
        ffmpegthumbnailer
        file
        freshplayerplugin
        gcc
        gcc-c++
        gedit
        git
        glib2-devel
        gstreamer
        gstreamer-plugins-bad
        gstreamer-plugins-base
        gstreamer-plugins-good
        gstreamer-plugins-good-extra
        gstreamer-plugins-good-gtk
        gstreamer-plugins-libav
        gstreamer-plugins-ugly
        gstreamer-plugins-vaapi
        gtk2-branding-openSUSE
        gtk2-engine-murrine
        gtk2-engines
        gtk3-branding-openSUSE
        gtk3-devel
        i3
        i3-gaps
        i3-gaps-devel
        i3lock
        i3status
        java-12-openjdk
        jsoncpp-devel
        kernel-devel
        libarchive13
        libcaca0
        libcairo2
        libcurl-devel
        libev4
        libev-devel
        libgstvdpau
        libiw-devel
        libjpeg62-devel
        libjpeg-turbo
        libjsoncpp19
        libmpdclient2
        libmpdclient-devel
        libnl3-200
        libnl3-devel
        libnotify4
        libnotify-devel
        libOSMesa8
        libOSMesa8-32bit
        libpulse0
        libpulse-devel
        libuser
        libva-vdpau-driver
        libvdpau1
        libvdpau_va_gl1
        libvdpau_va_gl1-32bit
        libvulkan1
        libvulkan1-32bit
        libvulkan_intel
        libvulkan_intel-32bit
        libvulkan_radeon
        libvulkan_radeon-32bit
        libX11-devel
        libxcb1
        libxcb-cursor0
        libxcb-ewmh2
        libxcb-image0
        libxcb-xrm0
        libXext-devel
        libxkbcommon0
        libxkbcommon-x11-0
        libxkbcommon-x11-devel
        lightdm
        lightdm-gtk-greeter-branding-upstream
        lsof
        lxappearance
        lynx
        make
        mediainfo
        Mesa
        Mesa-32bit
        Mesa-dri
        Mesa-dri-32bit
        Mesa-libd3d
        Mesa-libd3d-32bit
        Mesa-libEGL1
        Mesa-libEGL1-32bit
        Mesa-libGL1
        Mesa-libGL1-32bit
        Mesa-libglapi0
        Mesa-libglapi0-32bit
        Mesa-libGLESv1_CM1
        Mesa-libGLESv2-2
        Mesa-libOpenCL
        Mesa-libva
        Mesa-libVulkan-devel
        mpclient
        mpd
        mupdf
        nautilus
        ncmpcpp
        neofetch
        NetworkManager-applet
        NetworkManager-branding-openSUSE
        notification-daemon
        noto-mono-fonts
        noto-sans-fonts
        odt2txt
        pam-devel
        papirus-icon-theme
        pavucontrol
        pkgconf
        poppler-tools
        pulseaudio
        pulseaudio-utils
        python
        python3-chardet
        python3-devel
        python3-httpie
        python3-pip
        python3-Pygments
        python-xml
        ranger
        rofi
        rxvt-unicode
        scrot
        tar
        tmux
        transmission
        transmission-common
        unrar
        unzip
        vifm
        vim
        vulkan-headers
        vulkan-tools
        w3m
        wget
        wireless-tools
        xbacklight
        xcb-proto-devel
        xcb-util-cursor-devel
        xcb-util-devel
        xcb-util-image-devel
        xcb-util-wm-devel
        xcb-util-xrm-devel
        xf86-video-amdgpu
        xf86-video-ati
        xf86-video-intel
        xf86-video-nv
        xinput
        xrandr
        xrdb
        xz
        zip
        zlib-devel
        dummy-package-to-cancel-install
      "

      sudo zypper ar -cfp 90 https://download.nvidia.com/opensuse/tumbleweed nvidia
      sudo zypper inr -r nvidia
      check_packages "x11-video-nvidiaG05 nvidia-glG05 nvidia-gfxG05-kmp-default nvidia-computeG05 dummy-package-to-cancel-install"
      sudo zypper rr nvidia

      bash $DIR/../../setup-scripts/change-packman-mirror.sh
      check_packages "
        broadcom-wl
        flash-player-ppapi
        gstreamer-plugins-bad
        gstreamer-plugins-libav
        libgstvdpau
        dummy-package-to-cancel-install
      "

      sudo zypper rr packman-essentials

      break;;
  esac
done

