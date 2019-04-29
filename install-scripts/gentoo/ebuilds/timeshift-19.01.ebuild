
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools vala
DESCRIPTION="Improved improved screen locker - 'the ricing fork of i3lock'"
HOMEPAGE="https://github.com/teejee2008/timeshift"
SRC_URI="https://github.com/teejee2008/${PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND="
  dev-lan/vala
  dev-libs/libgee
  dev-libs/json-glib
  net-misc/rsync
  x11-libs/vte
"
RDEPEND="${DEPEND}"


