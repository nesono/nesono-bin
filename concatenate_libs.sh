#!/bin/bash
# script to concatenate static libs to reduce number of libs in a project
# written by iss
# date: 2006-01-23

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
