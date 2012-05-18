#!/usr/bin/env bash
# script to switch all compiler binaries to the
# specified version
# usage: switchgcc.sh <version>
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

