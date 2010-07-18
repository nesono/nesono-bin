#!/bin/bash
# check the status of several git repositories, sum the up in a mail and send
# the mail to the specified user
# written by jochen issing at 2009.08.28

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
