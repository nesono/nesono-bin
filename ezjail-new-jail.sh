#!/usr/bin/env sh

if [ -z "$1" ]; then
	echo "usage: -f template new.jail.name"
	exit 1
fi

ADDOPTS=""
if [ -z "`echo $@ | grep ' -f '" ]; then
	ADDOPTS="-f webserver"
fi

sorted_ezjail_ip_list=`ezjail-admin list | tail +3 | awk '{ print $3 }' | awk '{ \
	split($0, x, "."); \
	for(i=length(x); i>0; i--) \
		{ \
			if(i==1) \
				{ \
					printf "%d\n",x[i]; \
				} \
			else \
				{ \
					printf "%d.", x[i] ; \
				} \
			} \
		}' | sort -n |  awk '{ \
	split($0, x, "."); \
	for(i=length(x); i>0; i--) \
		{ \
			if(i==1) \
				{ \
					printf "%d\n",x[i]; \
				} \
			else \
				{ \
					printf "%d.", x[i] ; \
				} \
			} \
		}'`
#echo "sorted jail IPs: $sorted_ezjail_ip_list"

last_used_ip=`echo ${sorted_ezjail_ip_list} | awk '{ split($0, arr, " "); } END{ print arr[length(arr)] }'`
echo "last used ip:  $last_used_ip"

last_used_digit=`echo $last_used_ip | awk '{split($0,x,".")} END{print x[4]}'`
next_ip=${last_used_ip%.*}.`echo $last_used_digit+1 | bc`

#echo "last digit:    $last_used_digit"
echo "next ip:       $next_ip"

next_ip_available=`ifconfig lo1 | grep inet | grep $next_ip`
if [ -z "$next_ip_available" ]; then
	echo "need to create another alias"
	ifconfig lo1 alias $next_ip netmask 255.255.255.0
	last_alias_index=`cat /etc/rc.conf | grep ifconfig_lo1_alias | sed 's/ifconfig_lo1_alias\([0-9]*\)=.*/\1/' | tail -n1`
	next_alias_index=`echo $last_alias_index+1 | bc`
	echo "ifconfig_lo1_alias$next_alias_index=\"inet $next_ip netmask 255.255.255.0\"" >> /etc/rc.conf
else
	echo "next ip already available"
fi

ezjail-admin create $ADDOPTS $@ $next_ip
jail_name=`ezjail-admin list | grep 10.1.1.15 | awk '{print $4}' | tr "." "_"`

ezjail-admin start $jail_name

