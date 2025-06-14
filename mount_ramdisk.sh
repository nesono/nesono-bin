#!/usr/bin/env bash
# script to create and mount a ramdisk under Mac and Linux
# has one parameter: specifying the mount point
# to unmount, use the following command:
#  umount MOUNTPOINT
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

# command line check
if [ $# != 1 ]; then
  #print help and exit
  echo "Usage: $PROGNAME <mountpoint>"
  exit 255
fi

function createAndMountMac()
{
  # one sector are 512 bytes
  NUMSECTORS=128000
  mydev=$(hdid -nomount ram://$NUMSECTORS)
  newfs_hfs "$mydev"
  mkdir "${MOUNTPOINT}"
  mount -t hfs "$mydev" "${MOUNTPOINT}"
}

function createAndMountLinux()
{
  COUNTER=0
  while( true ); do
    DEVICE="/dev/ram${COUNTER}"
    MOUNTED=$(mount | grep "${DEVICE}")
    if [ -z "${MOUNTED}" ]; then
      if [ -e "$DEVICE" ]; then
        sudo mke2fs -m 0 ${DEVICE}
        sudo mount ${DEVICE} "${MOUNTPOINT}"
        # check, if mount succeeded
        MOUNTED=$(mount | grep "${DEVICE}")
        if [ -n "${MOUNTED}" ]; then
          echo "device ${DEVICE} mounted at ${MOUNTPOINT}"
          return 0
        fi
      else
        echo "no free device found!"
        echo "use mounted ramdisk or"
        echo "remount new one!"
        exit 255
      fi
    fi
    COUNTER=$((COUNTER+1))
  done
}

# remember mount point
MOUNTPOINT=$1
# get system uname
UNAME=$(uname -s)

echo "ramdisk will be mounted at ${MOUNTPOINT}"
# switch between different systems
case ${UNAME} in
  Darwin )
    echo " creating ramdisk for mac"
    createAndMountMac
  ;;
  Linux )
    echo " creating ramdisk for linux"
    createAndMountLinux
  ;;
esac
