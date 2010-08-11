#!/bin/bash
# script to test transfer stack functionality

# uses the following functions:
#
# transfers
# pusht
# popt

TESTDIR=/tmp/transstacktest.${RANDOM}
/bin/rm -rf ${TESTDIR}
echo "using testdir: \"${TESTDIR}\""
# create tmp directory and change into it
mkdir -p "${TESTDIR}" || echo "could not create testdir" && exit 1
# change into test dir
cd "${TESTDIR}" || echo "could not change into testdir" && exit 2

# create some directories
mkdir sub1 sub2 || echo "could not create subdirs" && exit 3
# change into sub1
cd sub1 || echo "could not change into sub1" && exit 4
# create some files
echo "test1" > test1.txt || echo "could not create testfile 1" && exit 5
echo "test2" > test2.txt || echo "could not create testfile 2" && exit 5
echo "test3" > test3.txt || echo "could not create testfile 3" && exit 5

# change into differen subdir
cd ../sub2 || echo "could not change into sub2" && exit 6
# push all created test files 3 times with different modes
pusht mv ../sub1/test1
pusht mv ../sub1/test2

pusht cp ../sub1/test1
pusht cp ../sub1/test2
pusht cp ../sub1/test3

pusht ../sub1/test1
pusht ../sub1/test2
pusht ../sub1/test3

pusht ../sub1/test1
pusht ../sub1/test2
pusht ../sub1/test3

# check transfers
[ "$(transfers | wc -l)" != 11 ] || echo "transfer list size 1 bad!" && exit 7
# change into other dir
cd ../sub2 || echo "could not change into sub2" && exit 7

# call first 3 items (test[1-3])
popt
popt
popt

# remaining:
# pusht mv ../sub1/test1
# pusht mv ../sub1/test2
#
# pusht cp ../sub1/test1
# pusht cp ../sub1/test2
# pusht cp ../sub1/test3
#
# pusht ../sub1/test1
# pusht ../sub1/test2
# pusht ../sub1/test3

# check transfers
[ "$(transfers | wc -l)" != 8 ] || echo "transfer list size 2 bad!" && exit 7

# check, if files here
[ -e ./test1 ] || echo "test1 file missing" && exit 8
[ -e ./test2 ] || echo "test2 file missing" && exit 8
[ -e ./test3 ] || echo "test3 file missing" && exit 8
# check, if source files still there
[ -e ../sub1/test1 ] || echo "test1 source file missing" && exit 9
[ -e ../sub1/test2 ] || echo "test2 source file missing" && exit 9
[ -e ../sub1/test3 ] || echo "test3 source file missing" && exit 9

# remove first copies
/bin/rm -f test1 test2 test3

# remove last 3 items
popt -d
popt -d
popt -d

# remaining:
# pusht mv ../sub1/test1
# pusht mv ../sub1/test2
#
# pusht cp ../sub1/test1
# pusht cp ../sub1/test2
# pusht cp ../sub1/test3

# check transfers
[ "$(transfers | wc -l)" != 5 ] || echo "transfer list size 3 bad!" && exit 7

# check, if files here
[ -e ./test1 ] && echo "test1 file where it should not be!" && exit 10
[ -e ./test2 ] && echo "test2 file where it should not be!" && exit 10
[ -e ./test3 ] && echo "test3 file where it should not be!" && exit 10

# pop all remaining items
popt -a

# remaining:
# nothing!

# check transfers
[ "$(transfers | wc -l)" != 0 ] || echo "transfer list size 4 bad!" && exit 7

# check, if files here
[ -e ./test1 ] || echo "test1 file missing" && exit 8
[ -e ./test2 ] || echo "test2 file missing" && exit 8
[ -e ./test3 ] || echo "test3 file missing" && exit 8

[ -e ./test1.0 ] || echo "test1.0 file missing" && exit 8
[ -e ./test2.0 ] || echo "test2.0 file missing" && exit 8
[ -e ./test3.0 ] && echo "test3.0 file where it should not be!" && exit 8

# check, if source files still there
[ -e ../sub1/test1 ] && echo "test1 source file still exits!" && exit 9
[ -e ../sub1/test2 ] && echo "test2 source file still exits!" && exit 9
[ -e ../sub1/test3 ] || echo "test3 source file missing" && exit 9

echo "test successfully passed :)"
echo "cleaning up..."
/bin/rm -rf ${TESTDIR}
echo "...done"
