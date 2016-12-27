#!/bin/sh

echo "ATTENTION"
echo ""
echo "This script stops and removes a jail including the ZFS jail with it."
echo "THE CHANGES ARE NOT REVERSIBLE!"
echo ""

if [ -z "$1" ]; then
	echo "jail.name missing"
	echo ""
	echo "usage: jail.name"
	exit 1
fi

jailname="$1"

echo """About to call the following commands

ezjail-admin stop $jailname 
ezjail-admin delete $jailname 
zfs unmount -f tank/ezjail/$jailname
zfs destroy tank/ezjail/$jailname
"""

read -e -p "Do you want to proceed? [y/N] " ANSWER
case "${ANSWER}" in
	"n"|"N"|"")
	echo "cancelled"
	exit 0
	;;
	"y"|"Y")
	echo "Last chance - waiting for 3 seconds:"
	echo " 3 "
	sleep 1
	echo " 2 "
	sleep 1
	echo " 1 "
	sleep 1
	;;
esac

error()
{
	echo $1
	exit 2
}

ezjail_check()
{
	ezjail-admin list | tail +3 | awk '{print $4}' | grep -e $1
}
zfs_check()
{
	zfs list tank/ezjail/$1 > /dev/null 2>&1
}

echo "sanity checks"
ezjail_check $jailname || error "No jail found with name \"$jailname\""
zfs_check $jailname || error "No ZFS jail found"

echo "Now I am serious"

ezjail-admin stop $jailname 
ezjail-admin delete $jailname 
zfs unmount -f tank/ezjail/$jailname
zfs destroy -r tank/ezjail/$jailname
echo "End of serious"
