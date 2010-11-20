#!/bin/bash
# script to switch all compiler binaries to the
# specified version
# usage: switchgcc.sh <version>

if [ -z "$1" ]; then
  echo "usage: $0 <version>"
  exit -1
fi

NEWGCC=$(which gcc-$1)
NEWGXX=$(which g++-$1)
NEWGCCBUG=$(which gccbug-$1)
NEWGCJ=$(which gcj-$1)
NEWGCJWRAPPER=$(which gcj-wrapper-$1)
NEWGCJH=$(which gcjh-$1)
NEWGCJHWRAPPER=$(which gcjh-wrapper-$1)
NEWGCOV=$(which gcov-$1)

LINKGCC=/usr/bin/gcc
LINKGXX=/usr/bin/g++
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
relink $NEWGXX $LINKGXX
relink $NEWGCCBUG $LINKGCCBUG
relink $NEWGCJ  $LINKGCJ
relink $NEWGCJWRAPPER $LINKGCJWRAPPER
relink $NEWGCJH  $LINKGCJH
relink $NEWGCJHWRAPPER $LINKGCJHWRAPPER
relink $NEWGCOV $LINKGCOV

