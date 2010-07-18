#!/bin/bash

DEFAULHOST=mx029
LOGFILENAME=$HOME/securesignaturecopy_log.txt
LOGFILEMAXLINES=300

# set up ping
TARGETHOST=${1:-$DEFAULHOST}
SUCCEEDED=`ping -c 1 $TARGETHOST | grep 'packets received' | awk '{ print $4; }'`

# do a log rotate (to decimate the log file length)
tail -n ${LOGFILEMAXLINES} ${LOGFILENAME} > ${LOGFILENAME}.new
mv ${LOGFILENAME}.new ${LOGFILENAME}

if [ "$SUCCEEDED" == "0" ]; then
  echo "host $TARGETHOST not reachable at `date `" >> ${LOGFILENAME}
  exit -2;
fi

# copy the signature to home folder
scp -q $TARGETHOST:/home/amm-archiv/orga/public/doc/signatures/$USER.txt_u.sig ~/ >> ${LOGFILENAME}
echo "signature copied at `date`" >> ${LOGFILENAME}

exit 0;
