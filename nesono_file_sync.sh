#!/bin/bash

FILE=$(basename ${1})

if [ -z "${FILE}" ]; then
  echo "not syncing complete home dir!"
  exit -1
fi

echo "syncing ${FILE}"

 /usr/bin/rsync -avuz nesono.com:~/${FILE} ~/ > /dev/null 2>&1
 /usr/bin/rsync -avuz ~/${FILE} nesono.com:~/ > /dev/null 2>&1
