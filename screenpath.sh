#!/bin/bash
# script to call repository status functions in screen's backtick

SCREENPATH=$(pwd | sed 's/\/home\//~/' | sed "s/~${USER}\(\/\)\?/~\//")
echo ${SCREENPATH}
