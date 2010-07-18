#!/bin/bash
# create a file with sorted disk usage of '/'
# outfile will be in home dir with date tag

DATETAG=`date +%Y-%m-%d`
echo "writing disk usage into file: $HOME/disk_usage_list.${DATETAG}.txt"
sudo du / | sort -n > $HOME/disk_usage_list.${DATETAG}.txt
echo "finished disk usage listing - written to file: $HOME/disk_usage_list.${DATETAG}.txt"
