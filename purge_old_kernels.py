#!/usr/bin/env python
# script to purge old kernels from linux installation (dpkg based) searches for
# installed kernels (linux-image-*) and removes all old kernels but the active
# and the second last as a backup
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

import os
import sys
import re
import operator
from collections import defaultdict
import apt

# function to calculate a key from kernel name
def kernel_hash( match ):
  # extract integers
  v1 = int(match.group(1))
  v2 = int(match.group(2))
  v3 = int(match.group(3))
  v4 = int(match.group(4))
  # create version integer
  #print v1*10**9 + v2*10**6 + v3*10**3 + v4
  return v1*10**9 + v2*10**6 + v3*10**3 + v4


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

num_installed = defaultdict(list)
# filter out kernel packages without numerics (virtual packages)
for item in installed:
  match = prog.match(item)
  if match:
    num_installed[kernel_hash(match)].append(item)
    #print 'version:',match.group(1),match.group(2),match.group(3),match.group(4)
    #print 'hash:   ',kernel_hash(match)

sorted_installed = sorted(num_installed.iteritems(), key=operator.itemgetter(0))

if len(sorted_installed) == 0:
  print 'exiting'
  sys.exit(0)

#for k,v in sorted_installed:
#  print k, ' content:', v
#print 'num installed: ', num_installed


# get latest installed kernel version (last entry)
latest = sorted_installed[-1]
latest_active = False
for kernel in latest[1]:
  if kernel == active:
    latest_active = True

# check if already latest installed kernel version active
if latest_active:
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
  for kernel in v:
    kernel_string += kernel + ' '

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
  for kernel in v:
    pkg = cache[kernel]
    pkg.mark_delete()
    print 'package',kernel,'is marked for delete',pkg.marked_delete

print 'committing changes'
# commit changes to apt
cache.commit()

print 'finished'
