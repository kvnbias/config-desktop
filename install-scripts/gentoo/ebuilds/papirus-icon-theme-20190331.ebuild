
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Papirus is a free and open source SVG icon theme for Linux"
HOMEPAGE="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme"
SRC_URI="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
 
DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${P}"

DESTDIR="/usr/share/icons"
THEMES=("Papirus" "ePapirus" "Papirus-Dark" "Papirus-Light")

src_compile() {
  echo "Nothing to compile."
}

src_install() {
  sudo mkdir -p "$DESTDIR"

  for theme in "${THEMES[@]}"; do
    test -d "${S}/$theme" || continue
    echo " ==> Installing '$theme' ..."
    sudo mkdir -p "${S}/$theme"
    sudo cp -raf "${S}/$theme" "$DESTDIR"
    sudo cp -raf \
      "${S}/AUTHORS" \
      "${S}/LICENSE" \
      "$DESTDIR/$theme" || true
  done

  # Try to restore the color of folders from a config
  if which papirus-folders > /dev/null 2>&1; then
    papirus-folders -R || true
  fi
}
