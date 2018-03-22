#!/usr/bin/env bash

set -e

if [ ! -d "$2" ]; then
	echo "usage: $0 <package name> <output dir>"
	echo " Note that the output directory needs to be created"
	echo " The output directory may contain debian packages"
	echo " which then will be added to the package listing"
	exit 1
fi

package_name=$1
output_folder=$2

cd $output_folder

echo "dependencies for package $package_name"
dependencies=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends $package_name | grep "^\w" | sort -u)

apt-get download $dependencies

dpkg-scanpackages . | gzip -9c > Packages.gz

echo "Package download done"
echo
echo "Once you finished adding packages, please add the folder to your apt.sources.list:"

echo "echo "deb [arch=arm64 trusted=yes] file://$(pwd) ./" | sudo tee -a /etc/apt/sources.list.d/$USER.list"
echo
echo "And then run"
echo "sudo apt-get update"
echo
