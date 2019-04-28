
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A systray-applet that allows you to control some of PulseAudio's features"
HOMEPAGE="https://github.com/fernandotcl/pa-applet"
SRC_URI="https://github.com/fernandotcl/pa-applet"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
 
DEPEND="
  dev-libs/glib
  x11-libs/libnotify
  x11-libs/libX11
  sys-devel/autoconf
  sys-devel/automake
  dev-util/pkgconf
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_compile() {
  echo "Nothing to compile."
}

src_install() {
  echo "Nothing to install"
}
