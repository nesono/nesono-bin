#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "usage: $0 file to encrypt"
	exit -1
fi
openssl enc -d -aes-256-cbc -in $1
