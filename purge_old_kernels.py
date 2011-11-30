#!/usr/bin/env python
# script to purge old kernels from linux installation (dpkg based) searches for
# installed kernels (linux-image-*) and removes all old kernels but the active
# and the second last as a backup

import os
import sys
import re
import operator
import apt

# to sort the kernels by version
class kernel_version:
  # init the instance with all version numbers
  def __init__(self,v1,v2,v3,v4):
    self.v1 = int(v1)
    self.v2 = int(v2)
    self.v3 = int(v3)
    self.v4 = int(v4)

  # compare with other instance for '<'
  def __lt__(self,other):
    #print 'comparing',self.v1,self.v2,self.v3,self.v4,'with',other.v1,other.v2,other.v3,other.v4
    if not (self.v1 == other.v1):
      return self.v1 < other.v1
    if not (self.v2 == other.v2):
      return self.v2 < other.v2
    if not (self.v3 == other.v3):
      return self.v3 < other.v3
    if not (self.v4 == other.v4):
      return self.v4 < other.v4

# all linux kernel packages start with this string
kernel_name_base = 'linux-image-'

# get current version
active = kernel_name_base+os.popen('uname -r').read().strip()
# the regular expression for version kernerl packages
prog = re.compile( kernel_name_base+'(\d+)\.(\d+)\.(\d+)-(\d+)-\w+.*' )

# get list of installed kernels
installed = os.popen('dpkg -l '+kernel_name_base+'\* | grep -e \'^ii\' | awk \'{print $2;}\'').read().strip()
# and split the string list
installed = installed.split('\n')

#print 'active:        ', active
#print 'installed:     ', installed
#print 'installed[0]:  ', installed[0]

num_installed = {}
# filter out kernel packages without numerics (virtual packages)
for item in installed:
  match = prog.match(item)
  if match:
    num_installed[kernel_version(match.group(1),match.group(2),match.group(3),match.group(4))] = item
    #print 'version:',match.group(1),match.group(2),match.group(3),match.group(4)

sorted_installed = sorted(num_installed.iteritems(), key=operator.itemgetter(0))

if len(sorted_installed) == 0:
  print 'exiting'
  sys.exit(0)

#for k,v in sorted_installed:
#  print k.v1,k.v2,k.v3,k.v4, ' content:', v
#print 'num installed: ', num_installed


# get latest installed kernel version (last entry)
latest = sorted_installed[-1]

# check if already latest installed kernel version active
if latest[1] == active:
  # active:
  print 'active kernel IS latest installed kernel'
else:
  # not active:
  print 'active kernel IS NOT latest installed kernel'
  print '  active:', active
  print '  latest:', latest[1]
  # ask to reboot
  print 'please reboot and restart this script'
  sys.exit(0)

# remove current kernel (and one backup) from list
to_purge = sorted_installed[0:-2]
if len( to_purge ) == 0:
  print 'nothing to purge :)'
  print 'exiting'
  sys.exit(0)

kernel_string = ''
# put together string for debugging
# combine kernels into string for deinstallation
for k,v in to_purge:
  kernel_string += v + ' '

# ask to delete old kernels
print 'command to purge kernels:'
print 'aptitude remove', kernel_string

answer = 'cont'
while( answer == 'cont' ):
  answer = raw_input('Apply? [Y/n] ')
  if answer == '':
    answer = 'y'
  if answer.lower()[0] == 'y':
    break
  if answer.lower()[0] == 'n':
    print 'aborting by user request'
    sys.exit(0)
  answer = 'cont'

# get apt cache
cache = apt.Cache()
# mark all packages for deletion
for k,v in to_purge:
  pkg = cache[v]
  pkg.mark_delete()
  print 'package',v,'is marked for delete',pkg.marked_delete

print 'committing changes'
# commit changes to apt
cache.commit()

print 'finished'
