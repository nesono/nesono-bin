#!/bin/bash
# script to delete a user and all its relations from a davical calendar...
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

# get application's name from argument list
APPNAME=`basename $0`

if [ $# != 1 ]; then
  echo "usage: ${APPNAME} <username>"
  exit 1
fi

USERNAME=${1}
DATABASE=davical
HOST=localhost

SQLDELUSER="BEGIN;
DELETE FROM relationship WHERE to_user = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM relationship WHERE from_user = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM collection WHERE user_no = (SELECT user_no FROM usr WHERE username='${USERNAME}');
DELETE FROM property WHERE dav_name LIKE '/${USERNAME}/%';
DELETE FROM usr WHERE username = '${USERNAME}';
COMMIT;"

echo "deleting user: ${USERNAME} from host: ${HOST} in database: ${DATABASE}"
psql -d ${DATABASE} -h ${HOST} <<< ${SQLDELUSER}

exit 0
