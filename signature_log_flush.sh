#!/bin/bash
# script to flush the signature copy log file
# leave specified number of lines in file

LINES=1000
LOGFILE=~/securesignaturecopy_log.txt

TMPFILE=/tmp/log.tmp
tail -n $LINES $LOGFILE > $TMPFILE
cp $TMPFILE $LOGFILE
