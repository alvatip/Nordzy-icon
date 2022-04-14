Name:		Nordzy-icon
Version:	1.3
Release:	1%{?dist}
Summary:	Free and open source icon theme

License:	GPLv3
URL:		https://github.com/alvatip/%{name}
Source0:	%{name}-%{version}.tar.gz

Requires:	hicolor-icon-theme,bash

BuildArch:	noarch

%description
Nordzy is a free and open source icon theme for Linux desktops.
It uses the Nord color palette from Arctic Ice Studio.
And is based on WhiteSur Icon Theme and Numix Icon Theme.
Currently, there are not that many icons...
I’ll take requests for which app icons I should put in next.
If I get no requests, I take (almost) randomly from the long list of apps.
Dark variants are more appropriate for dark desktop environments.
Normal variants are more appropriate for light desktop environments.

%prep
%setup -q

%build
# Nothing to do here

%install
mkdir -p "%{buildroot}%{_datadir}/icons"
cp -r %{_builddir}/%{name}-git* "%{buildroot}%{_datadir}/icons/%{name}"

%Check
# Nothing to do here

%files
%{_datadir}/icons/

%post
%{_datadir}/icons/%{name}/install.sh -d %{_datadir}/icons/ -t all

%preun
rm -rf %{_datadir}/icons/Nordzy*

%changelog
* Wed Apr 06 2022 - alvatip <alex.philippart@tutanota.com> - 1.3-1
- More new icons
- Better support for Cinnamon
- Icons optimization