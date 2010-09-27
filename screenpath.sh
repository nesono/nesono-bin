#!/bin/bash
# script to call repository status functions in screen's backtick

SCREENPATH=$(pwd | sed 's/\/home\//~/' | sed "s/~${USER}\(\/\)\?/~\//")
#[ ${#SCREENPATH} -gt 47 ] && SCREENPATH=..${SCREENPATH:${#SCREENPATH}-43}
echo ${SCREENPATH}
