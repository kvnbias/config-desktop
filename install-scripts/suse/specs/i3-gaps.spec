# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       i3-gaps
Version:    4.16.1
Release:    1%{?dist}
Summary:    i3-gaps is a fork of i3wm, a tiling window manager for X11

License:    BSD
URL:        https://github.com/Airblader/i3
Source0:    https://github.com/Airblader/i3/archive/%{version}.tar.gz

BuildArch:      x86_64

BuildRequires:  automake
BuildRequires:  gcc
BuildRequires:  libev-devel
BuildRequires:  libxcb-devel
BuildRequires:  libxkbcommon-devel
BuildRequires:  libxkbcommon-x11-devel
BuildRequires:  libXinerama-devel
BuildRequires:  libXrandr-devel
BuildRequires:  pcre-devel
BuildRequires:  pango-devel
BuildRequires:  startup-notification-devel
BuildRequires:  xcb-util-cursor-devel
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-keysyms-devel
BuildRequires:  xcb-util-wm-devel
BuildRequires:  xcb-util-xrm-devel
BuildRequires:  yajl-devel

Requires:       libev
Requires:       libxkbcommon-x11
Requires:       pango
Requires:       perl
Requires:       startup-notification
Requires:       xcb-util-cursor
Requires:       xcb-util-keysyms
Requires:       xcb-util-wm
Requires:       xcb-util-xrm
Requires:       yajl

Conflicts:      otherproviders(i3)

%description
i3-gaps is a fork of i3wm, a tiling window manager for X11

%global debug_package %{nil}

%prep
%setup -n i3-%{version}


%build
autoreconf -fi && rm -rf build/ && mkdir -p build && cd build
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make %{?_smp_mflags}


%install
cd build
%make_install


%files
%license LICENSE
%{_bindir}/i3
%{_includedir}/i3/
%dir %{_sysconfdir}/i3/
%config(noreplace) %{_sysconfdir}/i3/config
%config(noreplace) %{_sysconfdir}/i3/config.keycodes
%{_bindir}/i3-config-wizard
%{_bindir}/i3-dmenu-desktop
%{_bindir}/i3-dump-log
%{_bindir}/i3-input
%{_bindir}/i3-migrate-config-to-v4
%{_bindir}/i3-msg
%{_bindir}/i3-nagbar
%{_bindir}/i3-save-tree
%{_bindir}/i3-sensible-editor
%{_bindir}/i3-sensible-pager
%{_bindir}/i3-sensible-terminal
%{_bindir}/i3-with-shmlog
%{_bindir}/i3bar
/usr/share/applications/i3.desktop
/usr/share/xsessions/i3-with-shmlog.desktop
/usr/share/xsessions/i3.desktop





%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
