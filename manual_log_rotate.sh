#!/bin/bash
# author: spz
# script to force a log file rotation
#  that means
#  - an existing log file is moved
#  - its name is changed from xxx.log to xxx___DATE.log
#  - and SIGHUP is sent to the application that created the log file
#
# arguments are: the <logfile to be changed> and the <application name>
# modified and cleaned up by iss

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
