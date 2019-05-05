# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       i3lock-color
Version:    2.12.c
Release:    1%{?dist}
Summary:    Improved improved screen locker - 'the ricing fork of i3lock'

License:    BSD
URL:        https://github.com/PandorasFox/%{name}
Source0:    https://github.com/PandorasFox/%{name}/archive/%{version}.tar.gz

BuildArch:      x86_64

BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  cairo-devel
BuildRequires:  libev-devel
BuildRequires:  libjpeg62-devel
BuildRequires:  libxkbcommon-x11-devel
BuildRequires:  pam-devel
BuildRequires:  pkgconf
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-image-devel
BuildRequires:  xcb-util-xrm-devel

Requires:       libcairo2
Requires:       libev4
Requires:       libjpeg-turbo
Requires:       libxcb1
Requires:       libxcb-image0
Requires:       libxkbcommon0
Requires:       libxkbcommon-x11-0

Conflicts:      otherproviders(i3lock)

%description
Improved improved screen locker - 'the ricing fork of i3lock'

%prep
%setup


%build
autoreconf -fi
%configure
make %{?_smp_mflags}
echo "auth include system-auth" | tee i3lock


%install
%make_install
mkdir -p %{buildroot}/etc/pam.d
install -m 755 i3lock %{buildroot}/etc/pam.d/i3lock


%files
%license
%{_bindir}/i3lock
/etc/pam.d/i3lock
/usr/share/man/man1/i3lock.1.gz



%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
