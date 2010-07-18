#!/bin/bash
# script to switch all compiler binaries to the
# specified version
# usage: switchqt.sh <version>

TEMPCONFIG=`tempfile`
VERSION=${1}

HASQTVAR=''

function hasQtVariable()
{
  if [ -r ${1} ]; then
    echo `grep -e 'QTDIR' ${1}`
  else
    echo ''
  fi
}

function fixConfigFile()
{
   CONFIGFILE=${1}
   if [ -n "$(hasQtVariable ${CONFIGFILE})" ]; then
     cat ${CONFIGFILE} | sed -e "s/QTDIR=\/usr\/share\/qt./QTDIR=\/usr\/share\/qt$VERSION/g" > ${TEMPCONFIG}
     echo "bash config file (${CONFIGFILE}) patched"

     while ( true ); do
       echo ""
       read -p "would you like to install / view-diff / abort? [I/d/a] " COMMAND
       case ${COMMAND} in
         I|i)
           echo "overwriting old config file"
           mv ${TEMPCONFIG} ${CONFIGFILE}
           echo "finished"
           break
         ;;
         D|d)
           echo "diff from current config file to new one:"
           diff ${CONFIGFILE} ${TEMPCONFIG}
           echo ""
         ;;
         A|a|Q|q)
           echo "aborting"
           exit -1
         ;;
       esac
     done
   else
     echo "no QTDIR found in ${CONFIGFILE}"
   fi
}

# check for QTDIR variable in bash configuration files
fixConfigFile ~/.bashrc
fixConfigFile ~/.bash_profile
fixConfigFile ~/.profile

sudo update-alternatives --config moc
sudo update-alternatives --config uic
sudo update-alternatives --config qmake

