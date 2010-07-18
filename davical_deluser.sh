#!/bin/bash
# script to delete a user and all its relations from a davical calendar...

# get application's name from argument list
APPNAME=`basename $0`

if [ $# != 1 ]; then
  echo "usage: ${APPNAME} <username>"
  exit 1
fi

USERNAME=${1}
DATABASE=davical
HOST=localhost

SQLDELUSER="BEGIN;
DELETE FROM relationship WHERE to_user = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM relationship WHERE from_user = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM collection WHERE user_no = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM property WHERE dav_name LIKE '/${USERNAME}/%';
DELETE FROM usr WHERE username = '${USERNAME}';
COMMIT;"

echo "deleting user: ${USERNAME} from host: ${HOST} in database: ${DATABASE}"
psql -d ${DATABASE} -h ${HOST} <<< ${SQLDELUSER}

exit 0
