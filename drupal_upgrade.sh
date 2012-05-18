#!/usr/bin/env bash
# script to upgrade a drupal installation (the root)
#
# Copyright (c) 2012, Jochen Issing <iss@nesono.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# internal variables
APPNAME=${0##*/}
DOCROOT=/var/www
TMPDIR=/tmp/drpl_upgrade

# helper variables
hostname=$(hostname)
datestamp=$(date +'%Y-%m-%d')

# print help/usage
function printusage()
{
  echo "usage: ${APPNAME} [doc-root] drupal-x.yz.tar.gz"
}

# function to get the current date in iso format
function isodate()
{
  date +%Y-%m-%d
}

# copy if directory exists
function cond_cpdir()
{
  if [ -d ${1} ]; then
    echo "copying \"${1}\" to \"${2}\""
    cp -r ${1} ${2}
  else
    echo "${1} does not exist. skipped"
  fi
}

# check for user id (must be run as root)
if [ ${EUID} != 0 ]; then
  echo "script must be run as root! Recall me with sudo at least"
  exit 1
fi
# check, if first argument is a directory
if [ -d "${1}" ]; then
  DOCROOT=${1}
  shift
fi

# check nof input arguments
if [ $# == 0 ]; then
  printusage
  exit 1
elif [ ${1} == '-h' ]; then
  printusage
  exit 1
elif [ ${1} == '--help' ]; then
  printusage
  exit 1
fi

# check, if target directory exists
if [ ! -d ${DOCROOT} ]; then
  echo "Target directory '${DOCROOT}' does not exist!"
  read -e -p "Continue with new installation? [y/N]" ANSWER
  case "${ANSWER}" in
    y | Y )
      echo "New install not supported for now - sorry!"
      exit 3
      ;;
    * )
      echo "cancelling upgrade"
      echo ""
      exit 2
      break
      ;;
  esac
  echo "Exiting"
  exit 3
fi

# drupal archive is next parameter
DRPL_ARCHIVE=${1}

if [ -z "$(file ${DRPL_ARCHIVE} | grep 'gzip compressed data')" ]; then
  echo "Drupal archive no gzip archive!"
  echo "Aborting"
  exit 4
fi

echo "DRUPAL IS UPGRADED IN ${DOCROOT}"
echo "Verify, that this is correct!!!!!!"
echo ""

# ask user to get site into maintainer mode as user admin
echo "please"
echo "  -> put site to maintenance mode"
echo "  -> switch to garland theme"
echo "  -> maximize your shell - for vimdiff"

# verify garland theme by user request
while [ -z "$ANSWER" ]; do
  read -e -p "Go on? [y/N] " ANSWER
  case "$ANSWER" in
    y|Y )
      echo ""
      break
      ;;
    * )
      echo "cancelling by user request"
      echo ""
      exit 2
      break
      ;;
   esac
done

# stop web server
echo "stopping webserver"
apache2ctl stop
echo "stopped"

# backup mysql database
echo "checking for mysql debian info"
# get mysql debian maintainer and password
if [ ! -e /etc/mysql/debian.cnf ]; then
  echo "Error! Not a debian system - edit me!"
  exit -2
fi
mysqluser=$(cat /etc/mysql/debian.cnf | grep 'user' | tail -n 1 | awk '{ print $3;}')
mysqlpass=$(cat /etc/mysql/debian.cnf | grep 'password' | tail -n 1 | awk '{ print $3;}')

# backup whole mysql database
echo "backing up mysql"
# controls proceeding script if backup fails
proceed=y
mysqldump --user=${mysqluser} --password=${mysqlpass} --add-drop-table --all-databases > mysql_${hostname}_${datestamp}.sql
# check if last command succeeded
if [ ! $? -eq 0 ]; then
  # get root password from user
  echo "mysql backup failed - try using root from prompt"
  read -s -p "Please enter your mysql root password: " mysqlpass
  mysqluser=root
  echo "backing up mysql (next try)"
  mysqldump --user=${mysqluser} --password=${mysqlpass} --add-drop-table --all-databases > mysql_${hostname}_${datestamp}.sql
  # check for error - again
  if [ ! $? -eq 0 ]; then
    echo "Sorry, mysql backup did not succeed. Backup manually and come back!"
    proceed=n
    read -p "Backup done? [y/N]" proceed
  else
    proceed=y
  fi
fi

# check for proceeding script
if [ ${proceed} == "n" ] || [ ${proceed} == "N" ]; then
  echo "Execution aborted by user"
  echo "Bye!"
fi

echo "compressing mysql backup"
# compress mysql backup
bzip2 mysql_${hostname}_${datestamp}.sql

# get target installation path
echo "getting Drupal source base"
DRPL_SRCPATH=$(tar tvfz ${DRPL_ARCHIVE} | awk '{ print $6; }' | sed 's/\([.^\/]*\)\/.*/\1/' | uniq)
echo "Drupal source base: \"${DRPL_SRCPATH}\""

if [ -d "${DRPL_SRCPATH}" ]; then
  echo "Drupal source already existent! Move away \"${DRPL_SRCPATH}\""
  exit 5
fi

echo "creating tmp dir"
rm -rf ${TMPDIR}
mkdir -p ${TMPDIR}

if [ ! -d ${TMPDIR} ]; then
  echo "unable to create tmp directory!"
  echo "Aborting"
  exit 6
fi

echo "extracting drupal"
tar xvfz ${DRPL_ARCHIVE} -C ${TMPDIR}

if [ -e ${DOCROOT}/sites/default/settings.php ]; then
  echo "copying settings file to new installation"
  cp ${DOCROOT}/sites/default/settings.php ${TMPDIR}/${DRPL_SRCPATH}/sites/default/
  read -e -p "Do you want to edit settings.php with default-settings of new installation? [Y/n] " ANSWER
  case "${ANSWER}" in
    n|N )
      echo ""
      ;;
    * )
      echo "calling vimdiff - edit "
      vimdiff ${TMPDIR}/${DRPL_SRCPATH}/sites/default/*
      ;;
  esac
fi

# copy directories
cond_cpdir ${DOCROOT}/tmp                 ${TMPDIR}/${DRPL_SRCPATH}/
cond_cpdir ${DOCROOT}/files               ${TMPDIR}/${DRPL_SRCPATH}/
cond_cpdir ${DOCROOT}/sites/default/files ${TMPDIR}/${DRPL_SRCPATH}/sites/default/
cond_cpdir ${DOCROOT}/sites/all/modules   ${TMPDIR}/${DRPL_SRCPATH}/sites/all/
cond_cpdir ${DOCROOT}/sites/all/themes    ${TMPDIR}/${DRPL_SRCPATH}/sites/all/
cond_cpdir ${DOCROOT}/sites/all/libraries ${TMPDIR}/${DRPL_SRCPATH}/sites/all/

# change owner of archive to web server
chown -R www-data:www-data ${TMPDIR}/${DRPL_SRCPATH}

# remove old backup
rm -rf ${DOCROOT}.bup
mv ${DOCROOT} ${DOCROOT}.bup

# move new installation to docroot
mv ${TMPDIR}/${DRPL_SRCPATH} ${DOCROOT}

# start apache
apache2ctl start

echo "To finish installation, you need to "
echo "  -> call http://www.yoursite.com/update.php"
echo "  -> switch back from garland theme"
echo "  -> deactivate maintenance mode"
