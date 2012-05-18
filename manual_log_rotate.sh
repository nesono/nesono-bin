#!/usr/bin/env bash
# author: spz
# script to force a log file rotation
#  that means
#  - an existing log file is moved
#  - its name is changed from xxx.log to xxx___DATE.log
#  - and SIGHUP is sent to the application that created the log file
#
# arguments are: the <logfile to be changed> and the <application name>
# modified and cleaned up by iss
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

PROGNAME=`basename $0`

function printusage ()
{
  echo "usage: ${PROGNAME} logfile application"
}

# check cmdline arguments
if [ $# != 2 ]; then
  printusage
  exit -1;
fi

echo ""

# check if we have a running instance of $2
INSTANCE=`ps aux | grep $2 | grep -v grep | grep -v $0`
if [ -z "${INSTANCE}" ]; then
  echo "  no instance of $2 running"
  echo ""
  exit -1
fi

# this is our logfile to move
LOGFILE=$1

# check for our logfile
if [ -a $LOGFILE ]; then
  # the suffix for the logfile backup
  DATE=`date +%F__%k:%M:%S`
  # create backup filename from orig name
  NEW_FILE=`echo $LOGFILE | sed s/\.log/\___$DATE\.log/`

  echo "  trying to move $LOGFILE to $NEW_FILE"
  mv $LOGFILE $NEW_FILE
else
  echo "  logfile not found: $LOGFILE"
  echo ""
  exit -1
fi

echo " signal logfile change to: $2"
killall -HUP $2
