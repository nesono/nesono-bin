#!/bin/bash
# script to check, if the remote host has changed
# its ssh fingerprint.
# written by jochen.issing@iis.fraunhofer.de
# date: 2009-12-15

APPNAME=$(basename ${0})
RECEIPIENTS="server-admin"
TMPFILE=/tmp/${APPNAME}_output_mail.txt

if [ -z ${1} ]; then
  echo usage: ${APPNAME} remotehost
  exit -1
fi

# try a remote connection, parse output for 'Offending key'
OFFENDINGKEY=$(ssh ${1} exit 2>&1 | grep 'Offending key' )
#echo "offending key line: ${OFFENDINGKEY}"

# get line in known_hosts file of offending key
LINE=${OFFENDINGKEY##*:}
# cut off trailing carriage return (messed up print out)
LINE=${LINE%%}
# get file name of offending key file
KNOWNHOSTS=${OFFENDINGKEY%%:*}

if [ -n "${OFFENDINGKEY}" ]; then
  #cat | mail -s "ssh key offending!" ${RECEIPIENTS} <<-EOM
  cat > ${TMPFILE} <<EOM
Offending key found for host "${1}"!
Please remove line ${LINE} from your ssh known_hosts:
${KNOWNHOSTS}
and log into ${1} again
Otherwise, automatic scripts will fail!!!
EOM
  cat ${TMPFILE} | mail -s "ssh key offending!" ${RECEIPIENTS}
  echo ssh connection NOT SUCCEEDED
  echo remove line ${LINE} from your ssh known_hosts:
  echo ${KNOWNHOSTS}
  echo and log into ${1} again
else
  echo ssh connection succeeded
fi

