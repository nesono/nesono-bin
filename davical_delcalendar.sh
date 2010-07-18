#!/bin/bash
# script to delete a calendar from a davical server/database

# get application's name from argument list
APPNAME=`basename $0`

if [ $# != 1 ]; then
  echo "usage: ${APPNAME} <calendar-path>"
  echo "       e.g. ${APPNAME} '/user/calendar/home/'"
  exit 1
fi

CALENDARNAME=${1}
DATABASE=davical
HOST=localhost

SQLDELCALENDAR="DELETE FROM collection WHERE dav_name = '${CALENDARNAME}'"

echo "deleting calendar: ${CALENDARNAME} from host: ${HOST} in database: ${DATABASE}"
psql -d ${DATABASE} -h ${HOST} <<< ${SQLDELCALENDAR}

exit 0
