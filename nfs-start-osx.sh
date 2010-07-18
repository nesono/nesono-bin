#!/bin/bash
# script to start the nfs daemons

sudo /usr/sbin/mountd
sudo /sbin/nfsd -t -u -n 6
