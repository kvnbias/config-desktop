
# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3
DESCRIPTION="A systray-applet that allows you to control some of PulseAudio's features"
HOMEPAGE="https://github.com/fernandotcl/${PN}"
EGIT_REPO_URI="https://github.com/fernandotcl/${PN}.git"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
 
DEPEND="
  dev-libs/glib
  x11-libs/libnotify
  x11-libs/libX11
  media-sound/pulseaudio
  x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"
BDEPEND="
  virtual/pkgconfig
"

S="${WORKDIR}/${P}"

src_configure() {
  sh -c "$(pwd)/autogen.sh && $(pwd)/configure"
}

src_install() {
  if [[ -f Makefile ]] || [[ -f GNUmakefile ]] || [[ -f makefile ]] ; then
    emake DESTDIR="${D}" install
  fi

  einstalldocs
}
