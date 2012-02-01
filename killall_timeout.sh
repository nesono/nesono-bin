#!/bin/bash
# script to kill a certain application after a specific timeout
# using two incremental time out values - sending signal TERM
# after first timeout and KILL after second
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

if [ -z "$3" ]; then
  echo "Error in parameter list - usage:"
  echo "$0 <first_timeout_seconds> <second_timeout_seconds> application_name"
  exit -1
fi

FIRSTTIMEOUT=$1
SECONDTIMEOUT=$2
KILLAPP=$3

echo "timeouts for SIGTERM: $FIRSTTIMEOUT seconds and SIGKILL: $SECONDTIMEOUT seconds"
echo "killing app: $KILLAPP"

sleep $FIRSTTIMEOUT
killall -15 $KILLAPP
if [ $? != 0 ]; then
  echo "application no longer running - exiting killer script"
  exit 0
fi

sleep $SECONDTIMEOUT
killall -9 $KILLAPP
