#!/bin/sh
# script to reset all mixer channels in the hdsp mixer
# resulting an identity matrix as the mixer settings
# means Channel 0 -> 0
#       Channel 1 -> 1 ...

# channel mapping:
#   input:  0-25 (physical channels) 26-51 (audio output streams)
#   output: 0-27 (physical channels)

# therefore input  channels  0-25 are the interface input channels,
#           input  channels 26-51 are the output streams, where applications send their data to
#           output channels  0-27 are the interface output channels

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
