#!/bin/sh
# script to reset all mixer channels in the hdsp mixer
# resulting an identity matrix as the mixer settings
# means Channel 0 -> 0
#       Channel 1 -> 1 ...
#
# channel mapping:
#   input:  0-25 (physical channels) 26-51 (audio output streams)
#   output: 0-27 (physical channels)
#
# therefore input  channels  0-25 are the interface input channels,
#           input  channels 26-51 are the output streams, where applications send their data to
#           output channels  0-27 are the interface output channels
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

echo "resetting mixer matrix..."

for inputIndex in $(seq 0 51); do
  for outputIndex in $(seq 0 27); do
    # set volume from input 0-51 to output 0-27 to ZERO
    amixer -c 0 cset numid=5 $inputIndex,$outputIndex,0 
  done
done

echo "mixer set to ZERO"
echo "setting mixer matrix..."

#for inputIndex in $(seq 0 25); do
#  amixer -c 0 cset numid=5 $inputIndex,$inputIndex,32768 > /dev/null
#done

for inputIndex in $(seq 26 51); do
  #echo "amixer -c 0 cset numid=5 $inputIndex,$((inputIndex-26)),32768"
  amixer -c 0 cset numid=5 $inputIndex,$((inputIndex-26)),32768
done

echo "mixer ready"
