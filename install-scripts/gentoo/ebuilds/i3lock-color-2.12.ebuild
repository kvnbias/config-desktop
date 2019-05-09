
# x11-misc/i3lock-color
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools
DESCRIPTION="Improved improved screen locker - 'the ricing fork of i3lock'"
HOMEPAGE="https://github.com/PandorasFox/${PN}"
SRC_URI="https://github.com/PandorasFox/${PN}/archive/${PV}.c.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND="
  dev-libs/libev
  media-libs/libjpeg-turbo
  virtual/pam
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

src_install() {
  if [[ -f Makefile ]] || [[ -f GNUmakefile ]] || [[ -f makefile ]] ; then
    emake DESTDIR="${D}" install
  fi
  einstalldocs

  sudo mkdir -p "${D}/etc/pam.d"
  echo "auth include login" | sudo tee "${D}/etc/pam.d/i3lock"
}
