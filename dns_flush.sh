#!/usr/bin/env bash

if $(uname -r) == 14.0.0; then
	echo "flushing unicast dns cache"
	sudo discoveryutil udnscachestats
	echo "flushing multicast dns cache"
	sudo discoveryutil mdnsflushcache
	echo "done"
else
	echo "system not supported"
fi
