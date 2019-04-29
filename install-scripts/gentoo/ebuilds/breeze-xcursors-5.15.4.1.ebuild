
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3
DESCRIPTION="Breeze cursor theme (KDE Plasma 5). This package is for usage in non-KDE Plasma desktops."
HOMEPAGE="https://github.com/KDE/breeze"
EGIT_REPO_URI="https://github.com/KDE/breeze.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
  git checkout "v${PV}"
}

src_compile() {
  echo "Nothing to compile."
}

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

