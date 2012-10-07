#!/usr/bin/env bash
echo "script to rebuild launch service data base under mac os x"
echo "callind sudo to gain super user rights"
echo "if you don't trust me, just cancel me"
sudo /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user
