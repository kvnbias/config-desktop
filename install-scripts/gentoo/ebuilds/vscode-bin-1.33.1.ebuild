
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils
DESCRIPTION="Visual Studio Code is a streamlined code editor with support for development operations like debugging, task running, and version control."
HOMEPAGE="https://code.visualstudio.com"
SRC_URI="https://update.code.visualstudio.com/${PV}/linux-x64/stable -> ${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="x11-libs/libXScrnSaver"
RDEPEND="${DEPEND}"

S="${WORKDIR}/VSCode-linux-x64"

src_configure() {
  echo "Nothing to configure"
}

src_compile() {
  echo "Nothing to compile"
}

src_install() {
  echo "Copying files"
  sudo mkdir -p "${D}/usr/share/vscode"
  sudo cp -raf "${S}/." "${D}/usr/share/vscode/"
  sudo mkdir -p "${D}/usr/bin"
  sudo ln -sf "${D}/usr/share/vscode/bin/code" "${D}/usr/bin/code"
  sudo mkdir -p "${D}/usr/share/pixmaps"
  sudo cp "${S}/resources/app/resources/linux/code.png" "${D}/usr/share/pixmaps/code.png"
  make_desktop_entry "/usr/bin/code" "Code" "/usr/share/pixmaps/code.png" "TextEditor" "GenericName=Visual Studio Code"
}

pkg_postinst() {
  xdg_desktop_database_update
}

pkg_postrm() {
  xdg_desktop_database_update
}

