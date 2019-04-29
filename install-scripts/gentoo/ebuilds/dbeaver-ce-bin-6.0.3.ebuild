
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils
DESCRIPTION="Universal Database Client"
HOMEPAGE="https://dbeaver.com"
SRC_URI="https://github.com/dbeaver/dbeaver/releases/download/${PV}/dbeaver-ce-${PV}-linux.gtk.x86_64.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/dbeaver"

src_configure() {
  echo "Nothing to configure"
}

src_compile() {
  echo "Nothing to compile"
}

src_install() {
  echo "Copying files"
  sudo mkdir -p "${D}/usr/share/dbeaver-ce"
  sudo cp -raf "${S}/." "${D}/usr/share/dbeaver-ce/"
  sudo mkdir -p "${D}/usr/bin"
  sudo ln -sf "${D}/usr/share/dbeaver-ce/dbeaver" "${D}/usr/bin/dbeaver"
  sudo mkdir -p "${D}/usr/share/pixmaps"
  sudo cp "${S}/dbeaver.png" "${D}/usr/share/pixmaps/dbeaver.png"
  make_desktop_entry "/usr/bin/dbeaver" "Dbeaver Community Edition" "/usr/share/pixmaps/dbeaver.png" "Database" "GenericName=Universal Database Client"
}

pkg_postinst() {
  xdg_desktop_database_update
}

pkg_postrm() {
  xdg_desktop_database_update
}

