# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Graphical application for generating different color variations"
HOMEPAGE="https://github.com/themix-project/${PN}"

_OOMOX_GTK_THEME_VER=1.10
_MATERIA_THEME_VER=v20190315
_ARC_THEME_VER=20190330
_ARCHDROID_ICONS_VER=1.0.2
_GNOME_COLORS_ICONS_VER=5.5.5
_OOMOXIFY_VER=1.1.2
_BASE16_CMT=2e4112fe859ed5d33f67c177f11d369d360db9ae
_NUMIX_ICONS_CMT=88ba3654506c73f77a28629d863d1e23a553bff7
_NUMIX_FOLDERS_ICONS_CMT=24e5f6c6603e7f798553d2f24a00de107713c333
_PAPIRUS_ICONS_VER=20190501
_SURU_PLUS_ICONS_VER=v30.0
_SURU_PLUS_ASPROMAUROS_ICONS_VER=v2.1

SRC_URI="
  https://github.com/themix-project/oomox/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  https://github.com/themix-project/oomox-gtk-theme/archive/${_OOMOX_GTK_THEME_VER}.tar.gz -> oomox-gtk-theme-${_OOMOX_GTK_THEME_VER}.tar.gz
  https://github.com/nana-4/materia-theme/archive/${_MATERIA_THEME_VER}.tar.gz -> materia-theme-${_MATERIA_THEME_VER}.tar.gz
  https://github.com/NicoHood/arc-theme/archive/${_ARC_THEME_VER}.tar.gz -> arc-theme-${_ARC_THEME_VER}.tar.gz
  https://github.com/themix-project/oomox-archdroid-icon-theme/archive/${_ARCHDROID_ICONS_VER}.tar.gz -> archdroid-icon-theme-${_ARCHDROID_ICONS_VER}.tar.gz
  https://github.com/themix-project/oomox-gnome-colors-icon-theme/archive/${_GNOME_COLORS_ICONS_VER}.tar.gz -> gnome-colors-icon-theme-${_GNOME_COLORS_ICONS_VER}.tar.gz
  https://github.com/themix-project/oomoxify/archive/${_OOMOXIFY_VER}.tar.gz -> oomoxify-${_OOMOXIFY_VER}.tar.gz
  https://github.com/themix-project/base16_mirror/archive/${_BASE16_CMT}.tar.gz -> base16-${_BASE16_CMT}.tar.gz
  https://github.com/numixproject/numix-icon-theme/archive/${_NUMIX_ICONS_CMT}.tar.gz -> numix-icon-theme-${_NUMIX_ICONS_CMT}.tar.gz
  https://github.com/numixproject/numix-folders/archive/${_NUMIX_FOLDERS_ICONS_CMT}.tar.gz -> numix-folders-${_NUMIX_FOLDERS_ICONS_CMT}.tar.gz
  https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/${_PAPIRUS_ICONS_VER}.tar.gz -> papirus-icon-theme-${_PAPIRUS_ICONS_VER}.tar.gz
  https://github.com/gusbemacbe/suru-plus/archive/${_SURU_PLUS_ICONS_VER}.tar.gz -> suru-plus-${_SURU_PLUS_ICONS_VER}.tar.gz
  https://github.com/gusbemacbe/suru-plus-aspromauros/archive/${_SURU_PLUS_ASPROMAUROS_ICONS_VER}.tar.gz -> suru-plus-aspromauros-${_SURU_PLUS_ASPROMAUROS_ICONS_VER}.tar.gz
"

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

src_unpack() {
  tar xvzf ../distdir/${PN}-${PV}.tar.gz -C ${S} --strip-components=1
  tar xvzf ../distdir/oomox-gtk-theme-${_OOMOX_GTK_THEME_VER}.tar.gz -C ${S}/plugins/theme_oomox/gtk-theme --strip-components=1
  tar xvzf ../distdir/materia-theme-${_MATERIA_THEME_VER}.tar.gz -C ${S}/plugins/theme_materia/materia-theme --strip-components=1
  tar xvzf ../distdir/arc-theme-${_ARC_THEME_VER}.tar.gz -C ${S}/plugins/theme_arc/arch-theme --strip-components=1
  tar xvzf ../distdir/archdroid-icon-theme-${_ARCHDROID_ICONS_VER}.tar.gz -C ${S}/plugins/icons_archdroid/archdroid-icon-theme --strip-components=1
  tar xvzf ../distdir/gnome-colors-icon-theme-${_GNOME_COLORS_ICONS_VER}.tar.gz -C ${S}/plugins/icons_gnomecolors/gnome-colors-icon-theme --strip-components=1
  tar xvzf ../distdir/oomoxify-${_OOMOXIFY_VER}.tar.gz -C ${S}/plugins/oomoxify --strip-components=1
  tar xvzf ../distdir/base16-${_BASE16_CMT}.tar.gz -C ${S}/plugins/base16/base16_mirror --strip-components=1
  tar xvzf ../distdir/numix-icon-theme-${_NUMIX_ICONS_CMT}.tar.gz -C ${S}/plugins/icons_numix/numix-icon-theme --strip-components=1
  tar xvzf ../distdir/numix-folders-${_NUMIX_FOLDERS_ICONS_CMT}.tar.gz -C ${S}/plugins/icons_numix/numix-folders --strip-components=1
  tar xvzf ../distdir/papirus-icon-theme-${_PAPIRUS_ICONS_VER}.tar.gz -C ${S}/plugins/icons_papirus/papirus-icon-theme --strip-components=1
  tar xvzf ../distdir/suru-plus-${_SURU_PLUS_ICONS_VER}.tar.gz -C ${S}/plugins/icons_suruplus/suru-plus --strip-components=1
  tar xvzf ../distdir/suru-plus-aspromauros-${_SURU_PLUS_ASPROMAUROS_ICONS_VER}.tar.gz -C ${S}/plugins/icons/icons_suruplus_aspromauros/suru-plus-aspromauros --strip-components=1
}

