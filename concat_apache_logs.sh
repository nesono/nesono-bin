#!/bin/bash
# script to concatenate the apache log files
# in case of a problem with webalizer...



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
