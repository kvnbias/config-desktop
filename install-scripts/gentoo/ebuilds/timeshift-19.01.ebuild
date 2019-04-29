
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VALA_MIN_API_VERSION="0.40.14"
VALA_USE_DEPEND="vapigen"

inherit autotools vala
DESCRIPTION="Improved improved screen locker - 'the ricing fork of i3lock'"
HOMEPAGE="https://github.com/teejee2008/timeshift"
SRC_URI="https://github.com/teejee2008/${PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
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

src_prepare() {
  eapply_user
  vala_src_prepare
}

src_configure() {
  if [[ -x ${ECONF_SOURCE:-.}/configure ]] ; then
    econf
  fi

  rm -rfv ${D}/tmp/builds
  mkdir -pv ${D}/tmp/builds

  make clean

  rm -rfv ${S}/release/source
  mkdir -pv ${S}/release/source
}

