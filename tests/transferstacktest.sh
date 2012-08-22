#!/usr/bin/env bash
# script to test transfer stack functionality
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

# uses the following functions:
#
# transfers
# pusht
# popt

function debug()
{
  local msg=$1
	shift
  echo $msg
	$@
}

function assertcmd()
{
  local msg=$1
	shift
  $@
	if [[ $? != 0 ]]; then
	  echo $msg
		exit -1
	fi
}

function create_and_cd_test_dir()
{
	TESTDIR=/tmp/transstacktest.${RANDOM}
	/bin/rm -rf ${TESTDIR}
	echo "using testdir: \"${TESTDIR}\""
	# create tmp directory and change into it
	assertcmd "could not create testdir" mkdir -p "${TESTDIR}"
	# change into test dir
	assertcmd "could not change into testdir" cd "${TESTDIR}"

	echo "test dirs created successfully"
}

function create_and_cd_subdirs()
{
	# create some directories
	assertcmd "could not create subdirs" mkdir sub1 sub2
	# change into sub1
	assertcmd "could not change into sub1" cd sub1

	echo "created subdirs and changed into sub1 [`pwd`]"
}

function create_3_files()
{
	# create some files
	assertcmd "could not create testfile 1" echo "test1" > test1.txt
	assertcmd "could not create testfile 2" echo "test2" > test2.txt
	assertcmd "could not create testfile 3" echo "test3" > test3.txt

	echo "created files test1, test2, test3"
	echo "ls: `ls`"
}

function change_to_sub2()
{
	# change into differen subdir
	assertcmd "could not change into sub2" cd ../sub2

	echo "changed to sub2 [`pwd`]"
}

function push_transfers()
{
	# push all created test files 3 times with different modes
	pusht mv ../sub1/test1.txt &> /dev/null
	pusht mv ../sub1/test2.txt &> /dev/null
	pusht cp ../sub1/test3.txt &> /dev/null

	pusht cp ../sub1/test1.txt &> /dev/null
	pusht cp ../sub1/test2.txt &> /dev/null

	pusht ../sub1/test1.txt &> /dev/null
	pusht ../sub1/test2.txt &> /dev/null
	pusht ../sub1/test3.txt &> /dev/null
}

function apply_3_transfers()
{
  # call first 3 items (test[1-3])
  popt
  popt
  popt
}

function assert_list_len()
{
  # check transfers
  assertcmd "transfer removal failed -- is: `transfers | wc -l`, should be $1" [ "$(transfers | wc -l)" == "$1" ]

  echo "transfer list len correct"
}

function assert_copied_and_moved_1()
{
	# first two have been copied, last moved -- SRC
	assertcmd "test1 file missing" [ -e ./test1.txt ]
	assertcmd "test2 file missing" [ -e ./test2.txt ]
	assertcmd "test3 file missing" [ -e ./test3.txt ]

	# first two have been copied, last moved -- DST
	assertcmd "test1 source file still available" [ ! -e ../sub1/test1.txt ]
	assertcmd "test2 source file still available" [ ! -e ../sub1/test2.txt ]
	assertcmd "test3 source file missing"         [ -e ../sub1/test3.txt ]

  echo "files test[1-3] copied and moved correctly"
}

function rm_test_glob()
{
	# remove first copies
	/bin/rm -f test*.txt
}


function discard_3_transfers()
{
	# discard last 3 items
	popt -d
	popt -d
	popt -d
}

function assert_files_not_here()
{
	# check, if files here
	assertcmd "test1 file should not exist" [ -e ./test1.txt ]
	assertcmd "test2 file should not exist" [ -e ./test2.txt ]
	assertcmd "test3 file should not exist" [ -e ./test3.txt ]
}

function apply_all()
{
	# apply all remaining items
	popt -a
}

function assert_test3_here()
{
	# check, if files here
	assertcmd "test1 file should not exist" [ ! -e ./test1.txt ]
	assertcmd "test2 file should not exist" [ ! -e ./test2.txt ]
	assertcmd "test3 file missing"          [ -e ./test3.txt ]

	# check, if source files still there
	assertcmd "test1 source file still exits" [ ! -e ../sub1/test1.txt ]
	assertcmd "test2 source file still exits" [ ! -e ../sub1/test2.txt ]
	assertcmd "test3 source file missing    " [ -e ../sub1/test3.txt ]  
}

echo "nesono session cookie: $_NESONO_SESSION_COOKIE"
if [ -z "$_NESONO_SESSION_COOKIE" ]; then
  echo "No session cookie set"
	echo "Stopping tests before they could be started"
	exit -1
fi

create_and_cd_test_dir
create_and_cd_subdirs
create_3_files
change_to_sub2
push_transfers
popt -f
assert_list_len 0
push_transfers
assert_list_len 8
change_to_sub2
apply_3_transfers
assert_list_len 5
assert_copied_and_moved_1
rm_test_glob
discard_3_transfers
assert_list_len 2
assert_files_not_here
apply_all
assert_list_len 0
assert_test3_here
assert_src_moved


echo "test finished :)"
echo "cleaning up..."
/bin/rm -rf ${TESTDIR}
echo "...done"
