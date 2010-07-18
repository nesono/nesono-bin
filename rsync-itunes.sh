#!/bin/bash
# script to synchronize itunes library with local copy

# mail parameters
#RECEIPIENTS="testuser@test.com"

# remote host
REMOTEHOST=remotehost.com
# rsync parameters
HOSTNAME=`hostname`
REMOTEDIR=${REMOTEHOST}:~/Music
LOCALDIR=~/

# index directory
INPUTDIR=${LOCALDIR}Music/iTunes/iTunes\ Music/
INDEXDIR=$INPUTDIR/0000_last_added
rm -rf "$INDEXDIR"

######################################### synchronize directories
rsync -avz --delete ${REMOTEDIR} ${LOCALDIR}
chmod 755 ~/Music

######################################### create timely sorted index
rm -rf "$INDEXDIR"
TIMESORTDIRS=`find "$INPUTDIR" -iname \*.m4a -exec ls -l {} \; -o -iname \*.mp4 -exec ls -l {} \; -o -iname \*.mp3 -exec ls -l {} \;`
mkdir -p "$INDEXDIR"
pushd "$INDEXDIR"

# set IFS to newline only
IFS=$'\n'

for filespec in $TIMESORTDIRS; do
  if [ -n "$filespec" ]; then
    # get date of file
    date=`echo $filespec | awk '{print $6;}'`
    filename=${filespec#*/}

    # remove all path elements except for album name
    tmpfilename=${filename#*/}; filename=$tmpfilename
    tmpfilename=${filename#*/}; filename=$tmpfilename
    tmpfilename=${filename#*/}; filename=$tmpfilename
    tmpfilename=${filename#*/}; filename=$tmpfilename
    tmpfilename=${filename#*/}; filename=$tmpfilename


    # remove remaining slash (after album name)
    linkfilename=`echo $filename | tr '/ ' '_'`
    linkname=${date}_${linkfilename}
    if [ ! -d $date ]; then
      echo "creating dir: $date"
    fi
    mkdir -p $date
    ln -s ../../$filename $date/$linkname
  fi
done
popd

########################################## write an email that we have an updated list
echo "${HOSTNAME} Music share updated! look for: //${HOSTNAME}/music" | mail -s "automatic mail" $RECEIPIENTS

exit 0
