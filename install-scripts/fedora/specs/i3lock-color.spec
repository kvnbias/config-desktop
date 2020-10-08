# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       i3lock-color
Version:    2.12.c
Release:    5%{?dist}
Summary:    Improved improved screen locker - 'the ricing fork of i3lock'

License:    BSD
URL:       https://github.com/Raymo111/%{name}
Source0:   https://github.com/Raymo111/%{name}/archive/%{version}.5.tar.gz

BuildArch:      x86_64

BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  cairo-devel
BuildRequires:  libev-devel
BuildRequires:  libjpeg-devel
BuildRequires:  libxkbcommon-x11-devel
BuildRequires:  pam-devel
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-image-devel
BuildRequires:  xcb-util-xrm-devel

Requires:       cairo
Requires:       libev
Requires:       libjpeg-turbo
Requires:       libxcb
Requires:       libxkbcommon
Requires:       libxkbcommon-x11
Requires:       xcb-util-image
Requires:       pkgconf

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
