#!/bin/bash
# script to reload cisco vpn kernel module

BINARY="/System/Library/StartupItems/CiscoVPN/CiscoVPN"

if [ -x "${BINARY}" ]; then
  sudo "${BINARY}" restart
  exit 0
else
  echo "binary (${BINARY}) not found!"
  exit 1
fi
