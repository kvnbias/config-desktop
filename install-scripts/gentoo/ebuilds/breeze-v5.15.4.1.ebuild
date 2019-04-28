
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3
DESCRIPTION="A systray-applet that allows you to control some of PulseAudio's features"
HOMEPAGE="https://github.com/KDE/breeze"
EGIT_REPO_URI="https://github.com/KDE/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
 
DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_configure() {
  git checkout ${PV}
}

src_compile() {
  echo "Nothing to compile."
}

src_install() {
  echo "==> Installing Breeze cursor theme"
  sudo cp -raf "${S}/cursors/Breeze/Breeze/." "${D}/usr/share/icons/Breeze/"
  echo "==> Breeze cursor theme installed."
}

