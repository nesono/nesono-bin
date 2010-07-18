#!/bin/bash
# script to update all svn directories in current
# source directory

# go through all local directories
for item in *; do
  if [ -d "$item" ]; then
    # check, if directory has a dot in the name (backup?)
    if [ "$item" != "${item%.*}" ]; then
      echo "backup directory ignored: $item (period found in name!)"
      echo ""
    else
      # check, if we have an svn directory
      svn info $item > /dev/null 2>&1
      if [ "$?" == "0" ]; then
        echo "updating svn repository: \"$item\""
        # update svn directory
        svn update $item
        echo ""
      fi
    fi
  fi
done
