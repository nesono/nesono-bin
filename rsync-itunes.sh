#!/bin/bash
# script to synchronize itunes library with local copy
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
