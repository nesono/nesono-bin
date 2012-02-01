#!/bin/bash
# script to switch all compiler binaries to the
# specified version
# usage: switchqt.sh <version>
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

TEMPCONFIG=`tempfile`
VERSION=${1}

HASQTVAR=''

function hasQtVariable()
{
  if [ -r ${1} ]; then
    echo `grep -e 'QTDIR' ${1}`
  else
    echo ''
  fi
}

function fixConfigFile()
{
   CONFIGFILE=${1}
   if [ -n "$(hasQtVariable ${CONFIGFILE})" ]; then
     cat ${CONFIGFILE} | sed -e "s/QTDIR=\/usr\/share\/qt./QTDIR=\/usr\/share\/qt$VERSION/g" > ${TEMPCONFIG}
     echo "bash config file (${CONFIGFILE}) patched"

     while ( true ); do
       echo ""
       read -p "would you like to install / view-diff / abort? [I/d/a] " COMMAND
       case ${COMMAND} in
         I|i)
           echo "overwriting old config file"
           mv ${TEMPCONFIG} ${CONFIGFILE}
           echo "finished"
           break
         ;;
         D|d)
           echo "diff from current config file to new one:"
           diff ${CONFIGFILE} ${TEMPCONFIG}
           echo ""
         ;;
         A|a|Q|q)
           echo "aborting"
           exit -1
         ;;
       esac
     done
   else
     echo "no QTDIR found in ${CONFIGFILE}"
   fi
}

# check for QTDIR variable in bash configuration files
fixConfigFile ~/.bashrc
fixConfigFile ~/.bash_profile
fixConfigFile ~/.profile

sudo update-alternatives --config moc
sudo update-alternatives --config uic
sudo update-alternatives --config qmake

