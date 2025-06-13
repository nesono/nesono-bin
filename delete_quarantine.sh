#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo "usage: $0 /Application/AppInQuestion.app"
	exit 255
fi

sudo xattr -d com.apple.quarantine $1
