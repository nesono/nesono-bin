#!/bin/bash
# script to record cpu load for later display
# need file name for recording...

while ( true ); do
  VALUE=`top -b -n 1 -u $USER | grep Cpu\(s\) | sed 's/%us,//' | sed 's/%sy,//' | awk '{print $2+$3; }'`
  echo $VALUE
done
