
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils
DESCRIPTION="Visual Studio Code is a streamlined code editor with support for development operations like debugging, task running, and version control."
HOMEPAGE="https://code.visualstudio.com"
SRC_URI="https://update.code.visualstudio.com/${PV}/linux-x64/stable"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
 
#DEPEND="
#app-crypt/libsecret
#dev-util/pkgconfig
#x11-libs/libX11
#x11-libs/libxkbfile
#dev-lang/python:2.7
#"
DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
  echo "Nothing to configure"
}

src_compile() {
  echo "Nothing to compile"
}

src_install() {
  echo "Copying files"
  sudo mkdir -p "${D}/usr/vscode"
  sudo cp -raf "${S}/." "${D}/usr/vscode/"
  sudo mkdir -p "${D}/usr/bin"
  sudo ln -sf "${D}/usr/vscode/bin/code" "${D}/usr/bin/code"
}

pkg_postinst() {
  xdg_desktop_database_update
}

pkg_postrm() {
  xdg_desktop_database_update
}

