# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:		pa-applet
Version:	20181009
Release:	1%{?dist}
Summary:	Pulseaudio control applet

License:	BSD-2
URL:		https://github.com/fernandotcl/%{name}

BuildArch:      x86_64
BuildRequires:	glib2-devel gtk3-devel libnotify-devel pulseaudio-libs-devel libX11-devel autoconf automake pkgconf
Requires:	gtk3 libnotify pulseaudio-libs

%description
pa-applet is a sys-tray applet that allows you to control some of Pulseaudio's features

%prep
[ -d pa-applet ] && rm -rf pa-applet
git clone https://github.com/fernandotcl/pa-applet
cd pa-applet && ./autogen.sh


%build
cd pa-applet
%configure
make %{?_smp_mflags}


%install
cd pa-applet
%make_install


%files
%license
%{_bindir}/%{name}
/usr/share/man/man1/%{name}.1.gz



%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
