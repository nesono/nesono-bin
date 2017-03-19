#!/usr/bin/env python2

import subprocess as sp

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

jail_dict = get_jail_table()
if_list = get_if_table(jail_if)

if_free = jail_dict.viewkeys() ^ if_list

if not if_free:
    print("no interface for jails available, creating a new interface alias")
    ip_no_list = [int(x.split('.')[-1]) for x in jail_dict.keys()]
    highest_ip_no = sorted(ip_no_list)[-1]
    next_ip_no = highest_ip_no + 1
else:
    print("available interfaces for new jail:") 
    print(sorted(list(if_free))[0])

