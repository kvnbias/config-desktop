# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       nerd-fonts
Version:    2.0.0
Release:    1%{?dist}
Summary:    Iconic font aggregator, collection, and patcher.
Source0:    https://github.com/ryanoasis/nerd-fonts/raw/${PV}/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
Source1:    https://github.com/ryanoasis/nerd-fonts/raw/${PV}/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
Source2:    https://github.com/ryanoasis/nerd-fonts/raw/${PV}/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
Source3:    https://github.com/ryanoasis/nerd-fonts/raw/${PV}/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf

License:    MIT
URL:        https://nerdfonts.com/

BuildArch:      x86_64

%description
Iconic font aggregator, collection, and patcher. 40+ patched fonts, over 3,600 glyph/icons, includes popular collections such as Font Awesome & fonts such as Hack

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
