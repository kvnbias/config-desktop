# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Graphical application for generating different color variations"
HOMEPAGE="https://github.com/themix-project/${PN}"
SRC_URI="https://github.com/themix-project/${PN}/archive/${PN}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
  app-arch/zip
  dev-lang/sassc
  dev-libs/glib
  dev-libs/gobject-introspection
  dev-python/pillow
  dev-python/pygobject
  dev-python/pystache
  dev-python/pyyaml
  gnome-base/librsvg
  kde-frameworks/breeze-icons
  media-gfx/imagemagick
  media-gfx/inkscape
  media-gfx/optipng
  sys-apps/findutils
  sys-apps/grep
  sys-apps/sed
  sys-auth/polkit
  sys-devel/bc
  sys-process/parallel
  x11-apps/xrdb
  x11-libs/gdk-pixbuf
  x11-libs/gtk+:3
  x11-themes/gnome-themes-standard
  x11-themes/gnome-icon-theme-extras
  x11-themes/gtk-engines
  x11-themes/gtk-engines-murrine
"
RDEPEND="${DEPEND}"
