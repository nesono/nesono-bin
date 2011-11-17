#!/bin/bash

DIRECTORY="${1}"

if [ -z "${DIRECTORY}" ]; then
  echo "usage: ${0} directory"
  exit 31
fi
# remember active branch
ACTIVEBRANCH=`git branch | grep '*' | cut -d ' ' -f 2`

# create branch named as dir
git branch "${DIRECTORY}"
# checkout branch
git checkout "${DIRECTORY}"
# filter out everything else
git filter-branch -f --subdirectory-filter "${DIRECTORY}"/

# checkout original branch again
git checkout "${ACTIVEBRANCH}"
