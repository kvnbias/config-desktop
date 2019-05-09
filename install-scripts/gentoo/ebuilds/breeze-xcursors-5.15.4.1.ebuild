
# x11-themes/breeze-xcursors
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils
DESCRIPTION="Breeze cursor theme (KDE Plasma 5). This package is for usage in non-KDE Plasma desktops."
HOMEPAGE="https://github.com/KDE/breeze"
SRC_URI="https://github.com/KDE/breeze/archive/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/breeze-${PV}"

src_install() {
  echo "==> Installing Breeze cursor theme"
  sudo mkdir -p "${D}/usr/share/icons/Breeze/"
  sudo cp -raf "${S}/cursors/Breeze/Breeze/." "${D}/usr/share/icons/Breeze/"
  echo "==> Breeze cursor theme installed."
}

pkg_postinst() {
  xdg_icon_cache_update
}

pkg_postrm() {
  xdg_icon_cache_update
}

