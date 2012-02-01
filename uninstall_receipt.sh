#!/bin/bash
# script to uninstall bom archives -- needs file list of archive...
# usage: uninstall_bom.sh /Library/Receipts/receipt.pkg
#
# Copyright (c) 2012, Jochen Issing <iss@nesono.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

APP=`basename $0`

if [ $# != 1 ]; then
  echo "usage: ${APP} <xxx.pgk>"
  echo "       <xxx.pkg> the package file under /Library/Receipts"
  echo "                 which shall be uninstalled"
  exit -1
fi

# verbosity off by default
VERBOSE=0

# check for verbosity flags
if [ "$1" == "-v" ]; then
  VERBOSE=1
  shift
fi
if [ "$1" == "--verbose" ]; then
  VERBOSE=1
  shift
fi

# prealloc variables
FILES_TO_REM=""
DIRS_TO_REM=""
SYMLINKS_TO_REM=""

# prepare receipt file
RECEIPT="$1"
RECEIPT=${RECEIPT%%.pkg}.pkg
RECEIPT=/Library/Receipts/${RECEIPT##/Library/Receipts}

# resulting bom file
BOM_FILE="${RECEIPT}/Contents/Archive.bom"

if [ -f "${BOM_FILE}" ]; then
  if [ "${VERBOSE}" != "0" ]; then
    echo "using bom file: ${BOM_FILE}"
  fi
else
  echo "no bom file: ${BOM_FILE}"
  exit -1
fi

# function to move all files into Trash instead of deleting them directly
# to re-enable app trap..
function rm ()
{
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(date +%H-%M-%S)
      done
      mv "$path" ~/.Trash/"$dst"
    fi
  done
}

for item in `lsbom -p f "${BOM_FILE}" | sed 's@\./@/@' | sort -r`; do
  # check for file
  if [ -f "${item}" ]; then
    if [ "${VERBOSE}" != "0" ]; then
      echo "add file: ${item}"
    fi
    FILES_TO_REM="${FILES_TO_REM} ${item}"
  else
    # check for directory
    if [ -d "${item}" ]; then
      CONTENTS=`ls -l "${item}"`
      if [ -z "${CONTENTS}" ]; then
        if [ "${VERBOSE}" != "0" ]; then
          echo "add directory: ${item}"
        fi
        DIRS_TO_REM="${DIRS_TO_REM} ${item}"
      else
        if [ "${VERBOSE}" != "0" ]; then
          echo "not empty dir: ${item}"
        fi
      fi
    else
      # check for symbolic link
      if [ -L "${item}" ]; then
        if [ "${VERBOSE}" != "0" ]; then
          echo "add symbolic link: ${item}"
        fi
        SYMLINKS_TO_REM="${SYMLINKS_TO_REM} ${item}"
      else
        if [ "${VERBOSE}" != "0" ]; then
          echo "${item} is neither FILE nor DIRECTORY nor SYMBOLIC-LINK!"
        fi
      fi
    fi
  fi
done

echo ""
echo " SUMMARY: "
echo ""

# check, if any files of directories to delete
if [ -z "${FILES_TO_REM}" ]; then
  if [ -z "${DIRS_TO_REM}" ]; then
    if [ -z "${SYMLINKS_TO_REM}" ]; then
      echo "nothing to remove... savely removing receipient"
      # delete pacakge directory
      rm -r "${RECEIPT}"
      exit 0
    fi
  fi
fi

echo " files to remove: "
echo "${FILES_TO_REM}"
echo ""

echo " directories to remove: "
echo "${DIRS_TO_REM}"
echo ""

echo " symbolic links to remove: "
echo "${SYMLINKS_TO_REM}"
echo ""

# ask user whether to delete files and directories
echo "really delete? [N/y]"
read ANSWER

case $ANSWER in
  y|Y)
  echo "deleting files"
  rm -f ${FILES_TO_REM}

  echo "deleting directories"
  rm -rf ${DIRS_TO_REM}

  echo "deleting symbolic links"
  rm -f ${SYMLINKS_TO_REM}

  # delete pacakge directory
  rm -r "${RECEIPT}"

  echo "contents deleted and packge ${RECEIPT} removed"
  ;;

  n|N)
  echo "deletion aborted"
  exit -1
  ;;
esac

exit 0
