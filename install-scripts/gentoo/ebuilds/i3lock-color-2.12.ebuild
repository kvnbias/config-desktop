
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3
DESCRIPTION="Improved improved screen locker - 'the ricing fork of i3lock'"
HOMEPAGE="https://github.com/PandorasFox/i3lock-color"
SRC_URI="https://github.com/PandorasFox/i3lock-color/archive/${PV}.c.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND="
  dev-libs/libev
  media-libs/libjpeg-turbo
  x11-libs/cairo
  x11-libs/libxcb
  x11-libs/libxkbcommon
  x11-libs/xcb-util
  x11-libs/xcb-util-image
  x11-libs/xcb-util-xrm
  !x11-misc/i3lock
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}.c"

src_configure() {
  sh -c "autoreconf -fi && $(pwd)/configure"
}

src_compile() {
  sh -c "make"
}

src_install() {
  echo "==> Installing i3lock-color"
  sh -c "sudo make install"
  echo "==> i3lock-color theme installed."
  echo "auth include login" | sudo tee "${D}/etc/pam.d/i3lock"
}
