# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/


Name:       nerd-fonts
Version:    2.0.0
Release:    1%{?dist}
Summary:    Iconic font aggregator, collection, and patcher.

License:    MIT
URL:        https://nerdfonts.com/

BuildArch:      x86_64

%description
Iconic font aggregator, collection, and patcher. 40+ patched fonts, over 3,600 glyph/icons, includes popular collections such as Font Awesome & fonts such as Hack

%prep
mkdir -p nerd-fonts && cd nerd-fonts
wget -O "Ubuntu Mono Nerd Font Complete Mono.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/%{version}/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
wget -O "Roboto Mono Nerd Font Complete Mono.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/%{version}/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
wget -O "Roboto Mono Bold Nerd Font Complete Mono.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/%{version}/patched-fonts/RobotoMono/Bold/complete/Roboto%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf"
wget -O "Sauce Code Pro Nerd Font Complete Mono.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/%{version}/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf"


%build
# Nothing to configure

%install
cd nerd-fonts
mkdir -p "%{buildroot}/usr/share/fonts/nerd-fonts-complete/ttf"
install -m 755 "Ubuntu Mono Nerd Font Complete Mono.ttf" "%{buildroot}/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf" 
install -m 755 "Roboto Mono Nerd Font Complete Mono.ttf" "%{buildroot}/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf" 
install -m 755 "Roboto Mono Bold Nerd Font Complete Mono.ttf" "%{buildroot}/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf" 
install -m 755 "Sauce Code Pro Nerd Font Complete Mono.ttf" "%{buildroot}/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf" 


%files
%license
"/usr/share/fonts/nerd-fonts-complete/ttf/Ubuntu Mono Nerd Font Complete Mono.ttf"
"/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Nerd Font Complete Mono.ttf" 
"/usr/share/fonts/nerd-fonts-complete/ttf/Roboto Mono Bold Nerd Font Complete Mono.ttf" 
"/usr/share/fonts/nerd-fonts-complete/ttf/Sauce Code Pro Nerd Font Complete Mono.ttf" 


%changelog
* Thu May 02 2019 Kevin Baisas <kevin.baisas@gmail.com>
Initial spec
