#!/usr/bin/env bash

if [ -z "$1" ];
	echo "$usage: $0 application"
	exit -1
fi
osascript -e 'tell application "$1"' -e 'quit' -e 'end tell'