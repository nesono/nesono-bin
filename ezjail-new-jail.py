#!/usr/bin/env python2

import subprocess as sp
import os
import sys

if len(sys.argv) == 1:
	print("usage: %s -f template new.jail.name" % os.path.basename(sys.argv[0]))
	sys.exit(1)

jail_if = 'lo1'

def get_jail_table():
    ezjail_list = sp.check_output("ezjail-admin list", shell=True).splitlines()
    jail_table = [x.split() for x in ezjail_list[2:]]
    jail_dict = {x[2]:x for x in jail_table}
    return jail_dict

def get_if_table(jail_interface):
    interfaces = sp.check_output("ifconfig " + jail_interface + " | grep inet", shell=True).splitlines()
    if_table = [x.split() for x in interfaces]
    if_list = [x[1] for x in if_table]
    return if_list

def assert_jail_with_ip(ip):
    names = sp.check_output("ezjail-admin list | awk '{print $3, $4}'", shell=True).splitlines()[2:]
    jail_table = dict((k.strip(), v.strip()) for k,v in
            (item.split(' ') for item in names))
    if ip in jail_table:
        print("jail successfully added")
    else:
        raise RuntimeError("jail creation failed")

jail_dict = get_jail_table()
if_list = get_if_table(jail_if)

if_free = jail_dict.viewkeys() ^ if_list
next_ip = ""
if not if_free:
    print("no interface for jails available, creating a new interface alias for interface %s" % jail_if)
    ip_no_list = [int(x.split('.')[-1]) for x in jail_dict.keys()]
    highest_ip_no = sorted(ip_no_list)[-1]
    next_ip_no = highest_ip_no + 1
    print("creating alias with ip number %s" % next_ip_no)
else:
    print("available interfaces for new jail:") 
    print(sorted(list(if_free)))
    next_ip = sorted(list(if_free))[0]

assert(next_ip != "")

print("creating jail with name %s" % sys.argv[-1])
sp.check_output("ezjail-admin create %s %s" %(" ".join(sys.argv[1:]), next_ip), shell=True)

assert_jail_with_ip(next_ip)

print("starting jail")
sp.check_output("ezjail-admin start %s" % sys.argv[-1].replace(".","_"), shell=True)
