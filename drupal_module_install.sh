#!/usr/bin/env bash
# script to install/upgrade drupal modules and/or themes
# it supports installation or upgrade of multiple packages
# at a time, although all of these must be of the same
# type, either module or theme, because they will be
# installed in different locations
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

# Example module paths
#MODULEPATH=/var/www.test/sites/all/modules
#MODULEPATH=/Applications/XAMPP/htdocs/sites/all/modules

# parameters
MODULEPATH=/var/www/sites/all/modules
TRASHDIR=~/todel

# internal variables
APPNAME=${0##*/}
function printusage()
{
  echo "usage: ${APPNAME} [installation-dir] module-x.y.tar.gz [module_2-v.z.tar.gz ...]"
}
# function to get the current date in iso format
function isodate()
{
  date +%Y-%m-%d
}

# check, if first argument is a directory
if [ -d "${1}" ]; then
  MODULEPATH=${1}
  shift
fi

# check nof input arguments
if [ $# == 0 ]; then
  printusage
  exit 1
fi

# check, if target directory exists
if [ ! -d ${MODULEPATH} ]; then
  echo "Target directory '${MODULEPATH}' does not exist!"
  echo "Exiting"
  exit 3
fi

echo "All modules will be installed in ${MODULEPATH}"
echo "Verify, that this is correct!!!!!!"
echo ""
# ask user to get site into maintainer mode as user admin
echo "please activate MAINTENANCE MODE as user ADMIN!"

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

# create trash directory, if not existent
mkdir -p ${TRASHDIR}

# go through all input files
for file in $@; do
  # check for existence of input file
  if [ ! -r $file ]; then
    echo "file \"$file\" not readable/non-existent! Skipping!"
    printusage
    echo
    continue
  fi

  # truncate path
  MODNAME=${file##*/}
  # extract target path from input file
  MODNAME=${MODNAME%%-*}
  echo ""
  echo "######## ${MODNAME} ########"

  # check, if target path already exists and move it away if so
  if [ -e ${MODULEPATH}/${MODNAME} ]; then
    DATETAG=`isodate`
    while [ -e "~/${MODNAME}.${DATETAG}.old" ]; do
      DATETAG=`isodate`
    done
    echo "creating backup: ${TRASHDIR}/${MODNAME}.${DATETAG}.old"
    mv ${MODULEPATH}/${MODNAME} ${TRASHDIR}/${MODNAME}.${DATETAG}.old
  else
    echo "module not yet installed - performing new installation"
  fi

  # ready to unpack
  echo "installing ${file}..."
  tar xC ${MODULEPATH} -f ${file}
  echo "...done"
  # fixing permissions
  chown www-data:www-data -R ${MODULEPATH}

  # removing tarball
  echo "moving tarball to trash directory..."
  mv ${file} ${TRASHDIR}/
  echo "...done"
done

# echo print summary/finishing message
echo ""
sleep 1
echo "module installation done - please run modules update link as admin"
echo "and re-activate your site by leaving maintenance mode"
echo "Good bye :)"
