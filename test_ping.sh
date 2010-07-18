#!/bin/bash
# script to test if a host is reachable by ping
# useful for network using script to check, whether
# target host is reachable
# param 1: target host
# return val: 0 if available, otherwise any non-null value (see ping ret vals)

ping -c 1 $1 > /dev/null 2>&1
exit $?
