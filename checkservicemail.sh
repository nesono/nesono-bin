#!/bin/bash
# script to check for services and send a mail if any service is no longer available

RECEIPIENTS="server-admin"
TMPMAILFILE="/tmp/checkservicemail.tmp"

# clear SUBJECT
SUBJECT=""
# clear mail report tmpfile
cat > ${TMPMAILFILE} <<-ENDOFHEADER
Report for mail service check of host $(hostname)
The script already tries to respawn any broken
services back from hell, whenever an error has
been detected

ENDOFHEADER

AMAVISPORT=10024
CLAMAVPORT=10025
POSTGREYPORT=60000
APACHEPORT=80

# log function
function log()
{
  # append first parameter as string to mail report
  echo $1 | tee ${TMPMAILFILE}
  # append second parameter as string to subject
  SUBJECT="${SUBJECT} $2"
}

# sending mail function (dumps whole report and sends it to recipients)
function send_mail()
{
  cat ${TMPMAILFILE} | mail -s "${SUBJECT}" ${RECEIPIENTS}
}

## check amavis socket (10024)
#if [ -z "$(netstat -tuanp | egrep "\<${AMAVISPORT}\>")" ]; then
#  log "AMAVIS socket ${AMAVISPORT} no longer open!" "AMAVIS ERROR"
#  /etc/init.d/amavis restart &> /dev/null
#fi

# check postgrey socket (60000)
if [ -z "$(netstat -tuanp | egrep "\<${POSTGREYPORT}\>")" ]; then
  log "POSTGREY socket ${POSTGREYPORT} no longer open!" "POSTGREY ERROR"
  /etc/init.d/amavis restart &> /dev/null
fi

## check for clamav socket
#if [ ! -S /var/run/clamav/clamd.ctl ]; then
#  log "CLAMAV socket not available!" "CLAMAV socket ERROR"
#  /etc/init.d/clamav-daemon restart &> /dev/null
#fi

## check for clamav process
#if [ -z "$(pidof clamd)" ]; then
#  log "CLAMAV process not running! calling /etc/init.d/clamav-daemon restart" "CLAMAV process ERROR"
#  /etc/init.d/clamav-daemon restart &> /dev/null
#fi

# check for spamass-milter
if [ ! -S /var/spool/postfix/spamass/spamass.sock ]; then
  log "SPAMASS-MILTER socket not available!" "SPAMASS socket ERROR"
  /etc/init.d/spamass-milter restart &> /dev/null
fi

# check for apache running
if [ -z "$(netstat -tuanp | egrep "\<${APACHEPORT}\>")" ]; then
  log "APACHE socket ${APACHEPORT} no longer open!" "APACHE ERROR"
  /etc/init.d/apache2 restart &> /dev/null
fi

# check for dovecot socket
if [ ! -S /var/run/dovecot/auth-master ]; then
  log "DOVECOT socket not available!" "DOVECOT ERROR"
  /etc/init.d/dovecot restart &> /dev/null
fi

# check postfix status
if [ -z "$(netstat -tuanp | egrep ':\<25\>')" ]; then
  log "POSTFIX not running!" "POSTFIX ERROR"
  /etc/init.d/postfix restart &> /dev/null
fi

# check for mailman
if [ ! -f /var/run/mailman/mailman.pid ]; then
  log "MAILMAN service not running!" "MAILMAN pid ERROR"
  /etc/init.d/mailman restart &> /dev/null
fi

if [ -n "${SUBJECT}" ]; then
  send_mail
fi
