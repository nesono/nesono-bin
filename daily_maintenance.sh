#!/bin/bash
# script for daily maintenance of the server
# upgrades to packages
# discards orphaned packages, etc.

function check_and_update_svn_bin_repo()
{
  # parameter 1: local svn directory
  local DIR="${1}"

  # check, if dir existent
  if [ -d "${DIR}" ]; then
    # change into dir
    pushd "${DIR}" &> /dev/null
    # check, if dir is svn repo
    local REV=$(svn info 2>/dev/null | grep Revision | sed -e 's/Revision: //')
    [ "$REV" ] || return

    echo "### checking for svn repo: ${DIR}"
    # check for remote/repo changes
    if [ -n "$(svn st -u | grep -e '^[ ]\+\*')" ]; then
      echo "Remote changes detected in ${DIR}!"
      while ( true ); do
        read -e -p "Upgrade to repository or show diff? [Y/n/d] " ANSWER
        case "${ANSWER}" in
          "n"|"N")
          echo "not upgrading"
          break
          ;;
          "y"|"Y"|"")
          echo "upgrading"
          svn up
          break
          ;;
          "d")
          svn diff -r BASE:HEAD
          ;;
        esac
      done
    fi

    # check for local repo changes
    if [ -n "$(svn st | grep -e '^M')" ]; then
      echo "Local changes detected in ${DIR}!"
      while ( true ); do
        read -e -p "Checkin changes or show diff? [y/N/d] " ANSWER
        case "${ANSWER}" in
          "n"|"N"|"")
          echo "no check-in"
          break
          ;;
          "y"|"Y")
          echo "checking in ${DIR}"
          svn ci
          break
          ;;
          "d")
          svn diff
          ;;
        esac
      done
    fi
    echo "finished checking for svn repo: \"${DIR}\""
    popd &> /dev/null
  else
    echo "${DIR} not existent - ignoring"
  fi
}

function check_and_update_git_bin_repo()
{
  # parameter 1: local git directory
  local DIR="${1}"

  if [ -d "${DIR}" ]; then
    # change into repo dir
    pushd "${DIR}" &> /dev/null
    # check git call
    STATUS=$(git status --porcelain 2>/dev/null)
    [ $? -eq 128 ] && return

    echo "### checking for git repo: ${DIR}"
    if [ -n $(git remote | grep -e '^origin') ]; then
      echo "fetching remote changes - please apply afterwards"
      # get remote/repo changes
      git fetch
    else
      echo "Error: no origin specified in git repo"
    fi

    # check for local repo changes
    if [ -n "$(git status --porcelain | grep -e '^[ ]\+M')" ]; then
      echo "Local changes detected in ${DIR}!"
      while ( true ); do
        read -e -p "Checkin changes or show diff? [y/N/d] " ANSWER
        case "${ANSWER}" in
          "n"|"N"|"")
          echo "no check-in"
          break
          ;;
          "y"|"Y")
          echo "checking in ${DIR}"
          git commit -a -v
          echo "pushing changes"
          git push
          break
          ;;
          "d")
          git diff
          ;;
        esac
      done
    fi
    # get back to origin directory
    popd &> /dev/null
  else
    echo "\"${DIR}\" not existent - ignoring"
  fi
}
# check for user id (must be run as root)
if [ ${EUID} != 0 ]; then
  # check for mmt-bin directory and upgrade it, if neccessary - svn version
  check_and_update_svn_bin_repo ~/mmt-bin
  # check for nesono-bin directory and upgrade it, if neccessary - svn version
  check_and_update_svn_bin_repo ~/nesono-bin
  # check for mmt-bin directory and upgrade it, if neccessary - git version
  check_and_update_git_bin_repo ~/mmt-bin
  # check for nesono-bin directory and upgrade it, if neccessary - git version
  check_and_update_git_bin_repo ~/nesono-bin

  echo "script must be run as root! Recalling with sudo"
  sudo $0
  exit 0
fi

UNAME=$(uname -s)

# check for underlying system
case ${UNAME} in
  Linux)
  # Linux (with aptitude)

  # upgrade system
  echo "upgrading system"
  apt-get update
  apt-get -u dist-upgrade
  echo "upgrade finished"
  echo ""

  DEBORPHANBIN=$(which deborphan)
  if [ -n "${DEBORPHANBIN}" ]; then
    # purge orphaned pacakges
    ORPHANS=$(deborphan -n -s)
    if [ -n "${ORPHANS}" ]; then
      echo "purging orphans: ${ORPHANS}"
      apt-get autoremove --purge $(deborphan -n -s | awk '{print $2;}')
    else
      echo "no orphaned packages found"
    fi
    echo ""
  fi

  # autoremove old pacakges
  apt-get autoremove --purge

  # cleaning repository
  echo "autocleaning repository"
  apt-get autoclean
  ;;
  # End of Linux (with aptitude)


  Darwin)
  # Darwin (with macports)
  if [ -n $(which port) ]; then
    echo "port available"

    read -e -p "Shall I do selfupgrade? [y/N] " ANSWER

    case ${ANSWER} in
      "y" | "Y" )
        echo "running port selfupdate"
        # upgrade system
        port -c selfupdate
        ;;
    esac

    echo "sync'ing ports"
    port sync
    # show outdated ports
    OUTDATED=$(port list outdated)

    if [ -n "${OUTDATED}" ]; then
      read -e -p "Shall I upgrade the outdated ports? [Y/n] " ANSWER
      case ${ANSWER} in
        "" | "y" | "Y" )
          # upgrade system
          port upgrade outdated
          ;;
      esac
    else
      echo "no ports outdated"
    fi

  else
    echo "port not installed"
  fi

  # check for software update
  read -e -p "Shall I check for apple softwareupdate? [y/N] " ANSWER

  case ${ANSWER} in
    "y" | "Y" )
      TMPSTDOUT=/tmp/daily_maintenance.stdout.tmp
      TMPSTDERR=/tmp/daily_maintenance.stderr.tmp

      echo "getting list of available upgrades"
      # get list of available upgrade
      softwareupdate -l > ${TMPSTDOUT} 2> ${TMPSTDERR}
      if [ -z "$(cat ${TMPSTDERR})" ]; then
        cat ${TMPSTDOUT}
        # ask to apply updates
        read -e -p "Shall I apply softwareupdate? [a/r/N] " ANSWER

        case ${ANSWER} in
          "a" | "A" )
          softwareupdate -i -a
          ;;
          "r" | "R" )
          softwareupdate -i -r
          ;;
        esac
      fi
      /bin/rm -f ${TMPSTDOUT} ${TMPSTDERR}
      echo "softwareupdate finished"
      ;;
  esac
  ;;
  # End of Darwin
esac

