#!/bin/bash
# script to concatenate static libs to reduce number of libs in a project
# written by iss
# date: 2006-01-23
#
# Copyright (c) 2006, Jochen Issing <iss@nesono.com>
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

UNAME=`uname -s`

# function to print out usage
function printusage()
{
  echo ""
  echo "usage $0: targetlib.a libs_to_add.a ..."
  echo ""
  echo "      targetlib.a specified the resulting lib for the operation"
  echo "      libs_to_add.a is a list (space separated) of existing"
  echo "      libraries, which shall be concatenated"
  echo ""
}

function tempdir()
{
  TEMPDIR=`mktemp -q /tmp/concatenate_libs.XXXXXX`
  if [ $? -ne 0 ]; then
    echo "$0: Can't create temp dir, exiting..."
    exit 1
  fi
  rm $TEMPDIR
  mkdir $TEMPDIR
}

function tempname()
{
  TEMPNAME=`mktemp -q /tmp/concatenate_libs.XXXXXX`
  if [ $? -ne 0 ]; then
    echo "$0: Can't create temp name, exiting..."
    exit 1
  fi
  rm $TEMPNAME
}

# check cmdline arguments
if [ -z "$1" ]; then
  printusage;
  exit -1;
else
  if [ -z "$2" ]; then
    printusage;
    exit -1;
  fi
fi

# get target lib and discard it from cmdline
TARGETLIB=$1
shift

# create a temporal directory
tempdir

# remember current working directory
CURRENTWDIR=`pwd`
pushd $TEMPDIR

# go through list of libs
for lib_to_add in $@; do
  # regenerate absolute path
  lib_to_add=$CURRENTWDIR/$lib_to_add

  echo "################## extracting libary: $lib_to_add"

  # create a unique name
  tempname
  LIBPREFIX=${TEMPNAME##*/}

  # get all file names of the archive
  OBJECTS=`ar t ${lib_to_add}`

  # extract the lib
  ar x $lib_to_add

  # remove symlib files (from ranlib generated files...)
  rm -f __.SYMDEF*

  # rename the files to be unique
  for file in ${OBJECTS}; do
    if [ "$file" != "__.SYMDEF" -a "$file" != "SORTED" ]; then
      mv "$file" "$LIBPREFIX$file"
    fi
  done

done

echo "################### libtool target library composing: $TARGETLIB"
# add all files to the lib
if [ "$UNAME" == "Darwin" ]; then
  libtool -o $CURRENTWDIR/$TARGETLIB *
else
  ar rcs $CURRENTWDIR/$TARGETLIB *
fi

# remove all files from current lib before next lib extraction
rm *

echo "################### libs concatenation done"
popd

echo "################### removing temp directory"
rm -rf $TEMPDIR

exit 0;
