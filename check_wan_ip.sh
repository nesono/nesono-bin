#!/bin/sh
#
# Script for getting an external WAN IP
# depends on curl, awk, tr, sh, uniq
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

URLS[0]="http://checkip.dyndns.org"
URLS[1]="http://whatismyip.com"
URLS[2]="http://www.whatismyipaddress.com"
URLS[3]="http://ipid.shat.net"
URLS[4]="http://www.edpsciences.com/htbin/ipaddress"
URLS[5]="http://www.showmyip.com"

for URL in ${URLS[@]}
do
  THIS=${URL}
  echo "checking ${URL}..."
  IP=`curl -s "${THIS}" | tr -cs '[0-9\.]' '\012' \
          | awk -F'.' 'NF==4 && $1>0 && $1<256 && $2<256 && $3<256 && $4<256 && !/\.\./' | uniq`
  if [ $? == 0 ]; then
	  IP=`echo $IP | awk '{print $1}'`
	  echo "...succeeded"
	  echo "Your WAN IP Address is: $IP"
	  exit
  else
	  echo "...failed"
  fi
done
