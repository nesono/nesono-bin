#!/bin/bash
# script to test transfer stack functionality

. bashrc

# uses the following functions:
#
# transfers
# pusht
# popt

function debug()
{
  #echo $*
  return 1
}

TESTDIR=/tmp/transstacktest.${RANDOM}
/bin/rm -rf ${TESTDIR}
echo "using testdir: \"${TESTDIR}\""
# create tmp directory and change into it
mkdir -p "${TESTDIR}"    || echo "could not create testdir"
# change into test dir
cd "${TESTDIR}"          || echo "could not change into testdir"

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# create some directories
mkdir sub1 sub2          || echo "could not create subdirs"
# change into sub1
cd sub1                  || echo "could not change into sub1"

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# create some files
echo "test1" > test1.txt || echo "could not create testfile 1"
echo "test2" > test2.txt || echo "could not create testfile 2"
echo "test3" > test3.txt || echo "could not create testfile 3"

debug "contents: " && ls -lR ${TESTDIR}

# change into differen subdir
cd ../sub2 || echo "could not change into sub2"

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# push all created test files 3 times with different modes
pusht mv ../sub1/test1.txt
pusht mv ../sub1/test2.txt

pusht cp ../sub1/test1.txt
pusht cp ../sub1/test2.txt
pusht cp ../sub1/test3.txt

pusht ../sub1/test1.txt
pusht ../sub1/test2.txt
pusht ../sub1/test3.txt

pusht ../sub1/test1.txt
pusht ../sub1/test2.txt
pusht ../sub1/test3.txt

# check transfers
[ "$(transfers | wc -l)" != 11 ] || echo "transfer list size 1 bad!"
# change into other dir
cd ../sub2               || echo "could not change into sub2"

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

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

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# check transfers
[ "$(transfers | wc -l)" != 8 ] || echo "transfer list size 2 bad!"

# check, if files here
[ -e ./test1.txt ]           || echo "test1 file missing"
[ -e ./test2.txt ]           || echo "test2 file missing"
[ -e ./test3.txt ]           || echo "test3 file missing"
# check, if source files still there
[ -e ../sub1/test1.txt ]     || echo "test1 source file missing"
[ -e ../sub1/test2.txt ]     || echo "test2 source file missing"
[ -e ../sub1/test3.txt ]     || echo "test3 source file missing"

# remove first copies
/bin/rm -f test*.txt

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# remove last 3 items
popt -d
popt -d
popt -d

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# remaining:
# pusht mv ../sub1/test1
# pusht mv ../sub1/test2
#
# pusht cp ../sub1/test1
# pusht cp ../sub1/test2
# pusht cp ../sub1/test3

# check transfers
[ "$(transfers | wc -l)" != 5 ] || echo "transfer list size 3 bad!"

# check, if files here
[ -e ./test1.txt ]           && echo "test1 file where it should not be!"
[ -e ./test2.txt ]           && echo "test2 file where it should not be!"
[ -e ./test3.txt ]           && echo "test3 file where it should not be!"

# pop all remaining items
popt -a

debug "i am here: $(pwd)"
debug "contents: " && ls -lR ${TESTDIR}

# remaining:
# nothing!

# check transfers
[ "$(transfers | wc -l)" != 0 ] || echo "transfer list size 4 bad!"

# check, if files here
[ -e ./test1.txt ]           || echo "test1 file missing"
[ -e ./test2.txt ]           || echo "test2 file missing"
[ -e ./test3.txt ]           || echo "test3 file missing"

[ -e ./test1.txt.0 ]         || echo "test1.0 file missing"
[ -e ./test2.txt.0 ]         || echo "test2.0 file missing"
[ -e ./test3.txt.0 ]         && echo "test3.0 file where it should not be!"

# check, if source files still there
[ -e ../sub1/test1.txt ]     && echo "test1 source file still exits!"
[ -e ../sub1/test2.txt ]     && echo "test2 source file still exits!"
[ -e ../sub1/test3.txt ]     || echo "test3 source file missing"

echo "test finished :)"
echo "cleaning up..."
/bin/rm -rf ${TESTDIR}
echo "...done"