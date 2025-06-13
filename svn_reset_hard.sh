#!/usr/bin/env bash
# script to clean up svn tree:
# * revert all changes to the repo
# * remove all untracked files

if [[ $1 == "" ]]; then
  echo "please specify the path to the working copy explicitely"
	exit -1
fi

if [ ${1} == "." ]; then
  workingcopy=`pwd`
else
  workingcopy=$1
fi

echo "This will revert all changes and delete untracked files"
echo "in the following directory:"
echo "\"$workingcopy\""
echo ""
read -p "Are you sure? [y/N] " ANS
case $ANS in
	y* | Y* )
  ;;
	* )
  echo "cancelled"
  exit 0
	;;
esac

echo "Reverting working copy..."
svn revert -R $1
echo "...done"
echo "Removing untracked files..."
svn st $1 | grep '^?' | awk '{print $2}' | xargs rm -rf
echo "...done done"
