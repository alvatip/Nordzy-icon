#!/bin/bash

version=${1}
changelog=$(cat changelog)
temp=/var/temp

if [ -z ${1} ]; then
	echo "Version must be specified as an argument..."
	echo "Exiting script!"
	exit 1
fi

show_reminder(){
	echo '/!\ Ensure that fedora copr is properly set up on the computer and that the changelog was updated /!\'
	echo 'Press ctrl+C to cancel action'
	sleep 5
}

create_spec(){
	# do something
	echo "\
Name:		Nordzy-icon
Version:	${1}
Release:	1%{?dist}
Summary:	Free and open source icon theme

License:	GPLv3
URL:		https://github.com/alvatip/%{name}
Source0:	https://github.com/alvatip/%{name}/releases/tag/%{version}

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
mkdir -p \"%{buildroot}%{_datadir}/icons\"
cp -r %{_builddir}/%{name}-%{version} \"%{buildroot}%{_datadir}/icons/%{name}\"

%Check
# Nothing to do here

%files
%{_datadir}/icons/

%post
%{_datadir}/icons/%{name}/install.sh -d %{_datadir}/icons/ -t all

%preun
rm -rf %{_datadir}/icons/Nordzy*

%changelog
${changelog}
" > $HOME/rpmbuild/SPECS/nordzy-icon.spec
}

create_sources(){
	# Create an archive named after the version to put into SOURCE
	#note: the file must be renamec after Nordzy-icon-version_number before compression
	mkdir $HOME/Downloads/Nordzy-icon-${1}/
	cp -vr ../../../Nordzy-icon/* $HOME/Downloads/Nordzy-icon-${1}/
	cd $HOME/Downloads
	tar -zcvf ${1} Nordzy-icon-${1}/
	mv -v ${1} $HOME/rpmbuild/SOURCES/
}

clean(){
	rm -rf $HOME/Downloads/Nordzy-icon-${1}
	rm -rf $HOME/rpmbuild/{SOURCES,SPECS,BUILD,BUILDROOT,SRPMS,RPMS}/*
}

create_packages(){
	# Create the RPM package
	rpmbuild -ba $HOME/rpmbuild/SPECS/nordzy-icon.spec
}

upload_srpm(){
	# Upload the srpm on copr
	copr-cli build Nordzy-icon $HOME/rpmbuild/SRPMS/Nordzy-icon*.src.rpm
}

if [ -d $HOME/rpmbuild ]
then
	show_reminder
	create_sources ${version}
	create_spec ${version}
	create_packages
	upload_srpm
	clean ${version}
else
	echo "Check your setup"
fi
