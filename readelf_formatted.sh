#! /bin/bash
# the $1 for readelf is the first commandline parameter, the $7 and $1 are just for awk

readelf -S $1 | grep -e ' .text'   | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".text:   %10d\n", sum }'
readelf -S $1 | grep -e ' .rodata' | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".rodata: %10d\n", sum }'
readelf -S $1 | grep -e ' .data'   | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".data:   %10d\n", sum }'
readelf -S $1 | grep -e ' .bss'    | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".bss:    %10d\n", sum }'
