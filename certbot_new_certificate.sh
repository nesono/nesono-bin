#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo usage: $0 hostname
	exit -1
fi

hostname=$1

if [ -d /usr/local/etc/letsencrypt/live/$hostname ]; then
	echo "letsencrypt already has directory for hostname! Exiting"
	exit -2
fi

echo calling certbot certonly --webroot -w /tmp/letsencrypt-auto -d $hostname
certbot certonly --webroot -w /tmp/letsencrypt-auto -d $hostname
