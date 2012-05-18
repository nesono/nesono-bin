#!/usr/bin/env bash
# script to check, if the remote host has changed
# its ssh fingerprint.
# written by jochen.issing@iis.fraunhofer.de
# date: 2009-12-15
#
# Copyright (c) 2009, Jochen Issing <iss@nesono.com>
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
LINE=${LINE%%
}
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

