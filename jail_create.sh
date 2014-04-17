#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "usage: $0 <jailname>"
	echo "creates a new jail below /usr/jail/<jailname>"
	exit -1
fi

export D=/usr/jail/$1
mkdir -p $D
cd /usr/src
make buildworld
make installworld DESTDIR=$D
make distribution DESTDIR=$D
mount -t devfs devfs $D/dev
