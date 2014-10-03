#!/usr/bin/env bash

if [[ -z "$*" ]]; then
	echo "please specify the file pattern you want to ignore"
	exit 101
fi

is_global=0

# check if we are in a git repo
status=$(git status --porcelain 2> /dev/null)
DIRTY=""

if [[ $? -eq 128 ]]; then
	is_global=1
	gitignorefile="~/.gitignore"
	echo "not in a git repo"
else
	branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* //')
	git_repo_root=$(git rev-parse --show-toplevel)
	gitignorefile="$git_repo_root/.gitignore"

	[ -z "$(echo "$status" | grep -e '.gitignore' | grep -e '^ [RDMA]')" ] || DIRTY="*"
	[ -z "$(echo "$status" | grep -e '.gitignore' | grep -e '^?? ')"     ] || DIRTY="*"
	[ -z "$(echo "$status" | grep -e '^[RMDA]')"  ]                        || DIRTY="${DIRTY}+"
	echo "In git repo:"
	echo "     branch: $branch"
	echo "       root: $git_repo_root"
	echo "      dirty: $DIRTY"
	cd $git_repo_root
fi

read -n1 -r -s -p "Press any key to continue" key

echo "adding ignore lines $@"
echo "to $gitignorefile"
for entry; do
	echo $entry >> $gitignorefile
done

filename=$(git status --porcelain 2> /dev/null | grep -e '.gitignore' | awk '{print $2;}')
if [[ -n "$EDITOR" ]]; then
	$EDITOR $gitignorefile 
	if [[ $is_global -eq 0 ]]; then
		if [[ -z "$DIRTY" ]]; then
			git add $filename
			git commit -v
		else
			echo "Dirty working copy, please commit the change yourself"
		fi
	else
		echo "global ignore file, no commit neccessary"
	fi
else
	echo "EDITOR env var not set"
	echo "please open $gitignorefile,"
	echo "check the contents, and commit"
	echo "the change yourself (if in a repo"
fi
