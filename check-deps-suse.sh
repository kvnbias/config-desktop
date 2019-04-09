

os=$(echo -n $(cat /etc/*-release 2> /dev/null | grep ^ID= | sed -e "s/ID=//" | sed 's/"//g'))
sudo zypper -n update

check_packages() {
  sudo zypper install --no-recommends $1
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
        alsa-tools
        alsa-utils
        amd64-microcode
        arandr
        at
        atool
        autoconf
        automake
        breeze-cursor-theme
        broadcom-sta-dkms
        browser-plugin-freshplayer-pepperflash
        build-essential
        catdoc
        cmake
        compton
        conky
        curl
        dbus-x11
        dkms
        docx2txt
        dunst
        feh
        ffmpegthumbnailer
        file
        fonts-noto
        g++
        gcc
        gedit
        git
        gstreamer1.0-libav
        gstreamer1.0-plugins-bad
        gstreamer1.0-plugins-base
        gstreamer1.0-plugins-good
        gstreamer1.0-plugins-ugly
        gstreamer1.0-tools
        gstreamer1.0-vaapi
        gstreamer1.0-x
        gtk2-engines
        gtk2-engines-murrine
        httpie
        i3
        i3lock
        i3status
        libxcb-cursor0
        intel-microcode
        libarchive13
        libasound2
        libasound2-dev
        libcaca0
        libcairo2
        libcairo2-dev
        libcurl4-openssl-dev
        libd3dadapter9-mesa
        libegl-mesa0
        libev4
        libev-dev
        libgbm1
        libgl1-mesa-dri
        libglapi-mesa
        libglib2.0-dev
        libglu1-mesa
        libglw1-mesa
        libglx-mesa0
        libgtk2.0-0
        libgtk-3-0
        libgtk-3-dev
        libiw-dev
        libjsoncpp1
        libjsoncpp-dev
        libmpdclient2
        libmpdclient-dev
        libnl-3-200
        libnl-3-dev
        libnotify-bin
        libnotify-dev
        libosmesa6
        libpam0g-dev
        libpango1.0-0
        libpango1.0-dev
        libpcre3-dev
        libpulse0
        libpulse-dev
        libstartup-notification0
        libstartup-notification0-dev
        libturbojpeg0-dev
        libva-glx2
        libvdpau1
        libvdpau-va-gl1
        libvulkan1
        libx11-dev
        libxcb1
        libxcb-composite0
        libxcb-composite0-dev
        libxcb-cursor0
        libxcb-cursor-dev
        libxcb-ewmh2
        libxcb-ewmh-dev
        libxcb-icccm4
        libxcb-icccm4-dev
        libxcb-image0
        libxcb-image0-dev
        libxcb-keysyms1
        libxcb-keysyms1-dev
        libxcb-randr0
        libxcb-randr0-dev
        libxcb-util0-dev
        libxcb-xinerama0
        libxcb-xinerama0-dev
        libxcb-xrm0
        libxcb-xrm-dev
        libxext-dev
        libxinerama-dev
        libxkbcommon0
        libxkbcommon-dev
        libxkbcommon-x11-0
        libxkbcommon-x11-dev
        libxrandr-dev
        libyajl2
        libyajl-dev
        lightdm
        lightdm-gtk-greeter
        lightdm-gtk-greeter-settings
        linux-headers-$(uname -r)
        linux-image-$(uname -r)
        libxcb-randr0
        lsof
        lxappearance
        lynx
        make
        man-db
        mediainfo
        mesa-opencl-icd
        mesa-utils
        mesa-utils-extra
        mesa-va-drivers
        mesa-vdpau-drivers
        mesa-vulkan-drivers
        mpc
        mpd
        mupdf
        nautilus
        ncmpcpp
        neofetch
        network-manager
        network-manager-gnome
        odt2txt
        openjdk-11-jdk
        pavucontrol
        perl
        pkgconf
        poppler-utils
        psmisc
        pulseaudio
        pulseaudio-utils
        python
        python3-chardet
        python3-dev
        python3-pip
        python3-pygments
        python3-setuptools
        python-xcbgen
        ranger
        rofi
        rxvt-unicode
        scrot
        tar
        tmux
        transmission-cli
        transmission-common
        unrar
        unzip
        vifm
        vim
        vulkan-utils
        w3m
        wget
        wireless-tools
        x11-xserver-utils
        xbacklight
        xcb-proto
        xserver-xorg-video-amdgpu
        xserver-xorg-video-ati
        xserver-xorg-video-intel
        xz-utils
        zip
        zlib1g-dev
        dummy-package-to-cancel-install
      "

      if [ "$os" != "debian" ]; then
        check_packages "libjpeg62 libjpeg62-dev libturbojpeg dummy-package-to-cancel-install"
      else
        check_packages "
          firmware-linux-nonfree
          libjpeg62-turbo
          libjpeg62-turbo-dev
          libturbojpeg0
          libgl1-nvidia-glx
          nvidia-detect
          nvidia-driver
          nvidia-xconfig
          xserver-xorg-video-nvidia
          dummy-package-to-cancel-install
         "
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
        Mesa-libOSMesa8
        Mesa-libOSMesa8-32bit
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

      bash $(pwd)/scripts/change-packman-mirror.sh
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

