#!/bin/bash
# script to kill a certain application after a specific timeout
# using two incremental time out values - sending signal TERM
# after first timeout and KILL after second

if [ -z "$3" ]; then
  echo "Error in parameter list - usage:"
  echo "$0 <first_timeout_seconds> <second_timeout_seconds> application_name"
  exit -1
fi

FIRSTTIMEOUT=$1
SECONDTIMEOUT=$2
KILLAPP=$3

echo "timeouts for SIGTERM: $FIRSTTIMEOUT seconds and SIGKILL: $SECONDTIMEOUT seconds"
echo "killing app: $KILLAPP"

sleep $FIRSTTIMEOUT
killall -15 $KILLAPP
if [ $? != 0 ]; then
  echo "application no longer running - exiting killer script"
  exit 0
fi

sleep $SECONDTIMEOUT
killall -9 $KILLAPP
