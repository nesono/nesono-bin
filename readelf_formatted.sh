#!/usr/bin/env bash
# the $1 for readelf is the first commandline parameter, the $7 and $1 are just for awk
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

readelf -S $1 | grep -e ' .text'   | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".text:   %10d\n", sum }'
readelf -S $1 | grep -e ' .rodata' | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".rodata: %10d\n", sum }'
readelf -S $1 | grep -e ' .data'   | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".data:   %10d\n", sum }'
readelf -S $1 | grep -e ' .bss'    | sed 's/\[//' | sed 's/\]//' | awk '{ print "0x"$6 }' | xargs printf "%d\n" | awk ' { sum += $1 } END { printf ".bss:    %10d\n", sum }'
