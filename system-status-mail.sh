#!/bin/bash
# script to create a system status mail containing:
#
# write access to file system (touch)
# common kernel and machine information (uname -a)
# PC uptime (uptime)
# RAM status (free)
# disk free information (df -h)
# smart-monitor information
# current process table (top)

# target email addresses
EMAILS="server-admin"
# the system status file(s)
SYSTEMSTATFILE=${HOME}/system_status_file.txt
OLDSYSTEMSTATEFILE=${HOME}/system_status_file.txt.old
DIFFSTATUS=${HOME}/system_status_diff.txt
ENSCRIPT_PS=${HOME}/system_status_diff.ps
ENSCRIPT_PDF=${HOME}/system_status_diff.pdf
DIFFMAILFILE=${HOME}/system_status_diff_mail.html

# function to print one paragraph to the log mail
# $1 is the paragraph name
# $2 is the paragraph body
function toLogMail()
{
  # print paragraph name
  echo "$1" >> $SYSTEMSTATFILE
  # print paragraph body
  echo "$2" >> $SYSTEMSTATFILE
  # blank line to separate from next paragraph
  echo "" >> $SYSTEMSTATFILE
}

# backup old system status file
if [ -e $SYSTEMSTATFILE ]; then
  mv -f $SYSTEMSTATFILE $OLDSYSTEMSTATEFILE
fi

# check if file system is writable
touch ${HOME}/testfile
if [ "$?" == "0" ]; then
  echo "File System Writeable :-)" > $SYSTEMSTATFILE
  echo "" >> $SYSTEMSTATFILE
else
  # send mail
  echo "return value: $?"
  echo "FILE SYSTEM NOT WRITEABLE!!! FIX ME IMMEDIATELY!!! :-( :-( :-(" | mail -s "system status information" $EMAILS
  exit 1
fi

# check for gcc version
toLogMail "GCC version:" "$(gcc --version  | head -n 1)"

# common kernel and machine information
toLogMail "Kernel version" "$(uname -r)"

# PC uptime
toLogMail "Uptime" "$(uptime)"

# RAM status (free)
toLogMail "Processing overview" "$(top -b -n 1 | head -n 5)"

# disk free information (df -h)
toLogMail "Free disk space" "$(df -h)"

# smart-monitor information
toLogMail "S.M.A.R.T. monitor" "$(sudo /usr/sbin/smartctl -H -l error -l error /dev/sda | tail -n 6)"

# current process table (top) of iss' appliocations
toLogMail "Process table for iss:" "$(top -b -n 1 -u iss)"

# current process table (top)
toLogMail "Process table for all:" "$(top -b -n 1)"

# orphaned packages in apt-get
toLogMail "Orphaned packages:" "$(deborphan -n -s)"

# netstat output - available listening sockets and their applications
toLogMail "NETSTAT connections:" "$(netstat -tup)"

## diff to previous system status file
enscript -e -Ediffu --color --filter='diff %s.old %s | diffpp %s' system_status_file.txt -p - -whtml > $DIFFMAILFILE 2>/dev/null

# send mail(s)
#cat $SYSTEMSTATFILE | mail -s "$(hostname) system status information" $EMAILS
cat $DIFFMAILFILE   | mail -a "Mime-Version: 1.0" -a "Content-Type: text/html" -s "$(hostname) system status diff" $EMAILS
exit 0

