# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       i3-gaps
Version:    4.16.1
Release:    1%{?dist}
Summary:    i3-gaps is a fork of i3wm, a tiling window manager for X11

License:    GPLv3
URL:        https://github.com/Airblader/i3
Source0:    https://github.com/Airblader/i3/archive/%{version}.tar.gz

BuildArch:      x86_64
BuildRequires:  libxcb-devel xcb-util-keysyms-devel xcb-util-devel xcb-util-wm-devel xcb-util-xrm-devel yajl-devel libXrandr-devel startup-notification-devel libev-devel xcb-util-cursor-devel libXinerama-devel libxkbcommon-devel libxkbcommon-x11-devel pcre-devel pango-devel automake gcc
Requires:       libev libxkbcommon-x11 perl pango startup-notification xcb-util-cursor xcb-util-keysyms xcb-util-wm xcb-util-xrm yajl

%description
i3-gaps is a fork of i3wm, a tiling window manager for X11

%prep
%setup


%build
autoreconf -fi && rm -rf build/ && mkdir -p build && cd build
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make %{?_smp_mflags}


%install
%make_install


%files
%license



%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
