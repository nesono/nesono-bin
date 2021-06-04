#!/usr/bin/env bash

readonly polybar_module=$1
readonly count=$(checkupdates | wc -l)

if [ $count == 0 ]; then
    polybar-msg cmd hide.$polybar_module &> /dev/null
else
    polybar-msg cmd show.$polybar_module &> /dev/null
fi
echo $count
