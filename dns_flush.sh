#!/usr/bin/env bash

case "$(uname -r)" in
  14.* )
	echo "flushing unicast dns cache"
	sudo discoveryutil udnscachestats
	echo "flushing multicast dns cache"
	sudo discoveryutil mdnsflushcache
	echo "done"
	;;
  * )
	echo "system not supported"
	;;
esac
