#!/bin/bash
# check the status of several git repositories, sum the up in a mail and send
# the mail to the specified user
# written by jochen issing at 2009.08.28
#
# Copyright (c) 2009, Jochen Issing <iss@nesono.com>
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

RECEIPIENT="$1"
shift
REPOS="$@"

TMPMAILFILE=/tmp/$(basename $0).mailfile
echo "temporary mail file: ${TMPMAILFILE}"
# clean up temp mail file
echo "" > ${TMPMAILFILE}

echo "receipient(s): ${RECEIPIENT}"
echo "repositories to check: ${REPOS}"

for repo in ${REPOS}; do
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" | tee -a ${TMPMAILFILE}
  echo "" | tee -a ${TMPMAILFILE}
  echo "************ checking ${repo} ************ " | tee -a ${TMPMAILFILE}
  echo "" | tee -a ${TMPMAILFILE}

  if [ -d ${repo} ]; then
    # change into repository
    cd ${repo}
    # check for unstaged changes
    UNSTAGED=$(git diff)
    if [ -n "${UNSTAGED}" ]; then
      echo "UNSTAGED CHANGES IN REPO! :(" | tee -a ${TMPMAILFILE}
    else
      echo "no unstaged changes found :)" | tee -a ${TMPMAILFILE}
    fi
    # check for uncommited staged changes
    UNCOMMITED=$(git diff --cached)
    if [ -n "${UNCOMMITED}" ]; then
      echo "UNCOMMITED CHANGES IN REPO! :(" | tee -a ${TMPMAILFILE}
    else
      echo "no uncommited changes found :)" | tee -a ${TMPMAILFILE}
    fi
    # print out git status, if changes found
    if [ -n "${UNSTAGED}" -o -n "${UNCOMMITED}" ]; then
      # check general status
      echo "" | tee -a ${TMPMAILFILE}
      echo "git status tells us:" | tee -a ${TMPMAILFILE}
      git status | tee -a ${TMPMAILFILE}
    fi
    # add end line to mail file
    echo "" | tee -a ${TMPMAILFILE}
    echo "--------------------------------------------------------------------------------------" | tee -a ${TMPMAILFILE}
    echo "" | tee -a ${TMPMAILFILE}
  else
    echo " NOT A DIRECTORY: ${repo}!!!! " | tee -a ${TMPMAILFILE}
  fi
done

# mail file to receipients...
cat ${TMPMAILFILE} | mail -s "git admins repo observer" ${RECEIPIENT}
exit 0
