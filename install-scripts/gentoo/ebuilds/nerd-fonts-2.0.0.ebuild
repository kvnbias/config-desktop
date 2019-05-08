
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Iconic font aggregator, collection, and patcher. 40+ patched fonts, over 3,600 glyph/icons, includes popular collections such as Font Awesome & fonts such as Hack"
HOMEPAGE="https://nerdfonts.com"
SRC_URI="
https://github.com/ryanoasis/${PN}/raw/${PV}/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
https://github.com/ryanoasis/${PN}/raw/${PV}/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
https://github.com/ryanoasis/${PN}/raw/${PV}/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
https://github.com/ryanoasis/${PN}/raw/${PV}/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
  echo "Nothing to unpack"
  mkdir -p "${S}"
}

src_prepare() {
  echo "Preparing fonts"
  cp -raf "${S}/../../distdir/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"         "${S}/Ubuntu Mono Nerd Font Complete Mono.ttf"
  cp -raf "${S}/../../distdir/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"         "${S}/Roboto Mono Nerd Font Complete Mono.ttf"
  cp -raf "${S}/../../distdir/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf"  "${S}/Roboto Mono Bold Nerd Font Complete Mono.ttf"
  cp -raf "${S}/../../distdir/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf"    "${S}/Sauce Code Pro Nerd Font Complete Mono.ttf"
  eapply_user
}

src_configure() {
  echo "Nothing to configure"
}

src_compile() {
  echo "Nothing to compile"
}

src_install() {
  echo "Copying fonts"
  sudo mkdir -p "${D}/usr/share/fonts/${PN}-complete/ttf"
  sudo cp -raf "${S}/." "${D}/usr/share/fonts/${PN}-complete/ttf/"
}

