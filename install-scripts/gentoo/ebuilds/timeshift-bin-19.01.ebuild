
# app-backup/timeshift-bin
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VALA_MIN_API_VERSION="0.40"

inherit vala xdg-utils
DESCRIPTION="System restore tool for Linux. Creates filesystem snapshots using rsync+hardlinks, or BTRFS snapshots."
HOMEPAGE="https://github.com/teejee2008/timeshift"
SRC_URI="https://github.com/teejee2008/timeshift/releases/download/v${PV}/timeshift-v${PV}-amd64.run"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
 
DEPEND="
  dev-libs/libgee
  dev-libs/json-glib
  net-libs/libsoup
  net-misc/rsync
  sys-process/cronie
  x11-libs/vte
  $(vala_depend)
"
RDEPEND="${DEPEND}"

src_unpack() {
  echo "Unpacking timeshift-v${PV}-amd64.run file"
  mkdir -p "${S}"
  cp "${S}/../../distdir/timeshift-v${PV}-amd64.run" "$(pwd)"
  sh "timeshift-v${PV}-amd64.run" --noexec --target "${S}"
  echo "timeshift-v${PV}-amd64.run unpacked."
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
  echo "Copying /etc files"
  sudo mkdir -p "${D}/etc"
  sudo cp -raf "${S}/files/etc/." "${D}/etc/"

  echo "Copying /usr files"
  sudo mkdir -p "${D}/usr"
  sudo cp -raf "${S}/files/usr/." "${D}/usr/"
}

pkg_postinst() {
  xdg_desktop_database_update
}

pkg_postrm() {
  xdg_desktop_database_update
}


