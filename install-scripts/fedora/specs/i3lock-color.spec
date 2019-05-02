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
BuildRequires:  cairo-devel libev-devel libjpeg-devel libxkbcommon-x11-devel pam-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel autoconf automake
Requires:       cairo libev libjpeg-turbo libxcb libxkbcommon libxkbcommon-x11 xcb-util-image pkgconf

%description
Improved improved screen locker - 'the ricing fork of i3lock'

%prep
%setup -q


%build
%configure
make %{?_smp_mflags}
echo "auth include system-auth" | i3lock


%install
%make_install
mkdir -p %{buildroot}/etc/pam.d
install -m 755 i3lock %{buildroot}/etc/pam.d/i3lock


%files
%license
%{_bindir}/i3lock
/etc/pam.d/i3lock



%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
