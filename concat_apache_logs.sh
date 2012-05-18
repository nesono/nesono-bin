#!/usr/bin/env bash
# script to concatenate the apache log files
# in case of a problem with webalizer...
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


# function to zcat or cat a logfile
# $1 the log file path
# $2 the output log file
function xcat()
{
  # check for gzip file
  if [ "x${1##*.}" == "xgz" ]; then
    echo "found gzip file"
    zcat $1 >> $2
  else
    echo "found plain text file"
    cat $1 >> $2
  fi
}

# function to go through all log files of one prefix
# $1 prefix
# $2 outlog file
function concate_files()
{
  echo "" > $2

  # go through all input files
  for file in `ls -r ${1}access.log*`; do
    xcat $file $2
  done
}

# do the actual work
concate_files /var/log/apache2/          /var/log/apache2/access.full.log
concate_files /var/log/apache2/isign.    /var/log/apache2/isign.access.full.log
concate_files /var/log/apache2/h1427492. /var/log/apache2/h1427492.access.full.log
concate_files /var/log/apache2/mcf.      /var/log/apache2/mcf.access.full.log
