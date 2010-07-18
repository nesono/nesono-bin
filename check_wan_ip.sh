#!/bin/sh
#
# Script for getting an external WAN IP
#
# depends on curl, awk, tr, sh, uniq

URLS[0]="http://checkip.dyndns.org"
URLS[1]="http://whatismyip.com"
URLS[2]="http://www.whatismyipaddress.com"
URLS[3]="http://ipid.shat.net"
URLS[4]="http://www.edpsciences.com/htbin/ipaddress"
URLS[5]="http://www.showmyip.com"

for URL in ${URLS[@]}
do
  THIS=${URL}
  IP=`curl -s "${THIS}" | tr -cs '[0-9\.]' '\012' \
          | awk -F'.' 'NF==4 && $1>0 && $1<256 && $2<256 && $3<256 && $4<256 && !/\.\./' | uniq`
  if [ $? == 0 ]; then
    IP=`echo $IP | awk '{print $1}'`
    echo "Your WAN IP Address is: $IP"
    exit
  fi
done
