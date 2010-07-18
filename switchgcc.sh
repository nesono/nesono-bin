#!/bin/bash
# script to switch all compiler binaries to the
# specified version
# usage: switchgcc.sh <version>

if [ -z "$1" ]; then
  echo "usage: $0 <version>"
  exit -1
fi

NEWGCC=/usr/bin/gcc-$1
NEWGPP=/usr/bin/g++-$1
NEWCPP=/usr/bin/cpp-$1
NEWGCCBUG=/usr/bin/gccbug-$1
NEWGCJ=/usr/bin/gcj-$1
NEWGCJWRAPPER=/usr/bin/gcj-wrapper-$1
NEWGCJH=/usr/bin/gcjh-$1
NEWGCJHWRAPPER=/usr/bin/gcjh-wrapper-$1
NEWGCOV=/usr/bin/gcov-$1

LINKGCC=/usr/bin/gcc
LINKGPP=/usr/bin/g++
LINKCPP=/usr/bin/cpp-$1
LINKGCCBUG=/usr/bin/gccbug
LINKGCJ=/usr/bin/gcj
LINKGCJWRAPPER=/usr/bin/gcj-wrapper
LINKGCJH=/usr/bin/gcjh
LINKGCJHWRAPPER=/usr/bin/gcjh-wrapper
LINKGCOV=/usr/bin/gcov

function relink ()
{
  # check parameters
  if [ -x "$1" ]; then
    if [ -z "$2" ]; then
      echo "second argument empty for \"$1\"! need to specify link"
    else
      # do the actual linking
      echo "ln -sf $1 $2"
      sudo ln -sf $1 $2
    fi
  else
    echo "destination link not available: $1"
  fi
}

# relink all binaries
relink $NEWGCC  $LINKGCC
relink $NEWGPP $LINKGPP
relink $NEWCPP $LINKCPP
relink $NEWGCCBUG $LINKGCCBUG
relink $NEWGCJ  $LINKGCJ
relink $NEWGCJWRAPPER $LINKGCJWRAPPER
relink $NEWGCJH  $LINKGCJH
relink $NEWGCJHWRAPPER $LINKGCJHWRAPPER
relink $NEWGCOV $LINKGCOV

