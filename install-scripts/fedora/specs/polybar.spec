# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       polybar
Version:    3.3.1
Release:    1%{?dist}
Summary:     A fast and easy-to-use status bar

License:    MIT
URL:        https://polybar.github.io/
Source0:    https://github.com/jaagr/%{name}/archive/%{version}.tar.gz
Source1:	https://github.com/jaagr/i3ipcpp/archive/v0.7.1.tar.gz
Source2:	https://github.com/jaagr/xpp/archive/1.4.0.tar.gz

BuildArch:      x86_64

BuildRequires:  alsa-lib-devel
BuildRequires:  cairo-devel
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  jsoncpp-devel
BuildRequires:  libcurl-devel
BuildRequires:  libmpdclient-devel
BuildRequires:  libnl3-devel
BuildRequires:  pulseaudio-libs-devel
BuildRequires:  python
BuildRequires:  python2
BuildRequires:  pkgconf
BuildRequires:  xcb-proto
BuildRequires:  xcb-util-cursor-devel
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-image-devel
BuildRequires:  xcb-util-wm-devel
BuildRequires:  xcb-util-xrm-devel
BuildRequires:  wireless-tools-devel

Requires:       alsa-lib
Requires:       cairo
Requires:       curl
Requires:       jsoncpp
Requires:       libmpdclient
Requires:       libnl3
Requires:       pulseaudio-libs
Requires:       wireless-tools
Requires:       xcb-util-cursor
Requires:       xcb-util-image
Requires:       xcb-util-wm
Requires:       xcb-util-xrm

%description
The main purpose of Polybar is to help users create awesome status bars. It has built-in functionality to display information about the most commonly used services.

%prep
%setup


%build
rm -rf build/ && mkdir -p build && cd build && cmake ..
make %{?_smp_mflags}


%install
cd build
%make_install


%files
%license LICENSE



%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
