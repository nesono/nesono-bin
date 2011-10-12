#!/bin/bash

# script to fix davical permissions in one run
DBAUSER=davical_dba
APPUSER=davical_app
DBNAME=davical

echo "Fix Tables..."
for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" $DBNAME` ; do psql -c "alter table $tbl owner to $DBAUSER" $DBNAME; done
echo "... finished"

echo "Fix Views..."
for tbl in `psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" $DBNAME` ; do  psql -c "alter table $tbl owner to $DBAUSER" $DBNAME ; done
echo "... finished"

echo "Fix Sequences..."
for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" $DBNAME` ; do  psql -c "alter table $tbl owner to $DBAUSER" $DBNAME ; done
echo "... finished"
