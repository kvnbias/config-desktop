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
Source0:    https://github.com/jaagr/%{name}/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildArch:      x86_64

BuildRequires:  alsa-devel
BuildRequires:  cairo-devel
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  i3-gaps-devel
BuildRequires:  jsoncpp-devel
BuildRequires:  libcurl-devel
BuildRequires:  libiw-devel
BuildRequires:  libmpdclient-devel
BuildRequires:  libnl3-devel
BuildRequires:  libpulse-devel
BuildRequires:  pkgconf
BuildRequires:  python
BuildRequires:  python-xml
BuildRequires:  xcb-proto-devel
BuildRequires:  xcb-util-cursor-devel
BuildRequires:  xcb-util-devel
BuildRequires:  xcb-util-image-devel
BuildRequires:  xcb-util-wm-devel
BuildRequires:  xcb-util-xrm-devel

Requires:       alsa
Requires:       curl
Requires:       libcairo2
Requires:       libjsoncpp19
Requires:       libmpdclient2
Requires:       libnl3-200
Requires:       libpulse0
Requires:       libxcb-cursor0
Requires:       libxcb-ewmh2
Requires:       libxcb-image0
Requires:       libxcb-xrm0
Requires:       wireless-tools

%description
The main purpose of Polybar is to help users create awesome status bars. It has built-in functionality to display information about the most commonly used services.

%prep
rm -rf lib/i3ipcpp lib/xpp
%setup
rm -rf lib/i3ipcpp/* lib/xpp/*
git clone https://github.com/jaagr/i3ipcpp lib/i3ipcpp
git clone https://github.com/jaagr/xpp lib/xpp
cd lib/i3ipcpp && git checkout d4e4786 && cd ../../
cd lib/xpp && git checkout d2ff2aa && cd ../../



%build
rm -rf build/ && mkdir -p build && cd build && cmake ..
make 


%install
cd build
%make_install


%files
%license LICENSE
/usr/local/bin/polybar
/usr/local/bin/polybar-msg
/usr/local/share/bash-completion/completions/polybar
/usr/local/share/doc/polybar/config
/usr/local/share/man/man1/polybar.1
/usr/local/share/zsh/site-functions/_polybar
/usr/local/share/zsh/site-functions/_polybar_msg




%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
