#!/usr/bin/env bash
set -o errexit
set -o nounset

# Author: David Underhill
# Script to permanently delete files/folders from your git repository.
# Usage: ./git-remove-history.sh path1 path2 ...

print_help() {
  echo "Script to permanently delete files/folders from your git repository."
  echo "Usage: ./git-remove-history.sh path1 path2 ..."
  echo "Run this script from the root of your git repository."
}

if [ $# -eq 0 ]; then
  print_help
  exit 0
fi

# make sure we're at the root of git repo
if [ ! -d .git ]; then
  echo "Error: must run this script from the root of a git repository"
  print_help
  exit 1
fi

# remove all paths passed as arguments from the history of the repo
files=("$@")
git filter-branch --force --index-filter \
  "git rm -rf --cached --ignore-unmatch ${files[*]}" \
  --prune-empty --tag-name-filter cat -- --all

# remove the temporary history git-filter-branch otherwise leaves behind
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive
