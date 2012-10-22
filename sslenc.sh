#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "usage: $0 file to encrypt"
	exit -1
fi
openssl enc -aes-256-cbc -salt -in $1 -out $1.enc
