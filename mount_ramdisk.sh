#!/bin/bash
# script to create and mount a ramdisk under Mac and Linux
# has one parameter: specifying the mount point
# to unmount, use the following command:
#  umount MOUNTPOITN

APP=`basename $0`
# command line check
if [ $# != 1 ]; then
  #print help and exit
  echo "Usage: $PROGNAME <mountpoint>"
  exit -1
fi

function createAndMountMac()
{
  # one sector are 512 bytes
  NUMSECTORS=128000
  mydev=`hdid -nomount ram://$NUMSECTORS`
  newfs_hfs $mydev
  mkdir ${MOUNTPOINT}
  mount -t hfs $mydev ${MOUNTPOINT}
}

function createAndMountLinux()
{
  COUNTER=0
  while( true ); do
    DEVICE="/dev/ram${COUNTER}"
    MOUNTED=`mount | grep "${DEVICE}"`
    if [ -z "${MOUNTED}" ]; then
      if [ -e "$DEVICE" ]; then
        sudo mke2fs -m 0 ${DEVICE}
        sudo mount ${DEVICE} ${MOUNTPOINT}
        # check, if mount succeeded
        MOUNTED=`mount | grep "${DEVICE}"`
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
UNAME=`uname -s`

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
