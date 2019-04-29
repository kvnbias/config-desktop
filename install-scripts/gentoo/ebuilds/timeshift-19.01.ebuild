
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VALA_MIN_API_VERSION="0.40"
VALA_USE_DEPEND="vapigen"

inherit vala
DESCRIPTION="Improved improved screen locker - 'the ricing fork of i3lock'"
HOMEPAGE="https://github.com/teejee2008/timeshift"
SRC_URI="https://github.com/teejee2008/timeshift/releases/download/v19.01/timeshift-v19.01-amd64.run"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
 
DEPEND="
  dev-libs/libgee
  dev-libs/json-glib
  net-libs/libsoup
  net-misc/rsync
  x11-libs/vte
  $(vala_depend)
"
RDEPEND="${DEPEND}"

src_unpack() {
  echo "Nothing to unpack"
  mkdir -p "${S}"
}

src_prepare() {
  echo "Nothing to prepare"
  eapply_user
}

src_configure() {
  echo "Nothing to configure"
}

src_compile() {
  echo "Nothing to compile"
}

src_install() {
  sh ../../distdir/timeshift*amd64.run
}
