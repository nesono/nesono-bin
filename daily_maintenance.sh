#!/bin/bash
# script for daily maintenance of the server
# upgrades to packages
# discards orphaned packages, etc.
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

# get system uname
UNAME=$(uname -s)

function check_and_update_svn_bin_repo()
{
  # parameter 1: local svn directory
  local DIR="${1}"

  # check, if dir existent
  if [ -d "${DIR}" ]; then
    # change into dir
    pushd "${DIR}" &> /dev/null
    echo "### checking if svn repo: ${DIR}"
    # check, if dir is svn repo
    local REV=$(svn info 2>/dev/null | grep Revision | sed -e 's/Revision: //')
    [ "$REV" ] || return

    echo "### checking for svn repo: ${DIR}"

    # check if repo accessible
    svn st -u &> /dev/null
    if [ ! $? == 0 ]; then echo "### Can not access repository! Stopping update"; echo ''; return; fi

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
    popd &> /dev/null
    echo ""
  fi
}

function check_and_update_git_bin_repo()
{
  # parameter 1: local git directory
  local DIR="${1}"

  if [ -d "${DIR}" ]; then
    # change into repo dir
    pushd "${DIR}" &> /dev/null
    echo "### checking if git repo: ${DIR}"
    # check git call
    STATUS=$(git status --porcelain 2>/dev/null)
    [ $? -eq 128 ] && return

    REMOTEUP=1
    # check if remote repo (origin) is reachable
    git fetch origin &> /dev/null
    if [ ! $? == 0 ]; then REMOTEUP=0; fi

    echo "### checking for git repo: ${DIR}"
    if [ -n $(git remote | grep -e '^origin') ]; then
      # check if remote accessible at all
      if [ ${REMOTEUP} == 0 ]; then
        echo "### Can not access depot! Skipping rebase"
      else
        # get remote/repo changes
        git pull --rebase
      fi
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

          if [ ${REMOTEUP} == 0 ] ;then
            echo "depot not reachable - skipping git push"
            echo "remember to call it manually as soon as"
            echo "depot reachable again"
          else
            echo "pushing changes"
            git push
          fi
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
    echo ""
  fi
}

function check_and_update_homebrew()
{
  # check if brew command available
  if [ -x "$(which brew)" ]; then
    echo "### brew available"

    echo "### running brew update"
    # update repo
    brew update

    # show outdated ports
    OUTDATED=$(brew outdated)

    if [ -n "${OUTDATED}" ]; then
      read -e -p "Shall I upgrade the outdated formulas? [Y/n] " ANSWER
      case ${ANSWER} in
        "" | "y" | "Y" )
          # upgrade system
          brew upgrade ${OUTDATED}
          ;;
      esac
    else
      echo "no formulas outdated"
    fi

  else
    echo "### brew not installed"
  fi
  echo ""
}

function check_and_update_macports
{
  # check for mac ports binary
  if [ -x "$(which port)" ]; then
    echo "### port available"

    echo "### running port selfupdate"
    # upgrade system
    port -c selfupdate

    # show outdated ports
    OUTDATED=$(port list outdated)

    if [ -n "${OUTDATED}" ]; then
      read -e -p "Shall I upgrade the outdated ports? [Y/n] " ANSWER
      case ${ANSWER} in
        "" | "y" | "Y" )
          # upgrade system
          port -u upgrade outdated
          ;;
      esac
    else
      echo "no ports outdated"
    fi

  else
    echo "### port not installed"
  fi
  echo ""
}

function mac_software_update_interactive()
{
  # ask to check for software update
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
  echo ""
}

function check_and_update_aptget()
{
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
      apt-get autoremove $(deborphan -n -s | awk '{print $2;}')
    else
      echo "no orphaned packages found"
    fi
    echo ""
  fi

  # autoremove old pacakges
  apt-get autoremove

  # cleaning repository
  echo "autocleaning repository"
  apt-get autoclean

  echo ""
}

if [ "$1" != "--no-bin-check" ]; then
  # check for mmt-bin directory and upgrade it, if neccessary - svn version
  check_and_update_svn_bin_repo ~/mmt-bin
  # check for nesono-bin directory and upgrade it, if neccessary - svn version
  check_and_update_svn_bin_repo ~/nesono-bin
  # check for mmt-bin directory and upgrade it, if neccessary - git version
  check_and_update_git_bin_repo ~/mmt-bin
  # check for nesono-bin directory and upgrade it, if neccessary - git version
  check_and_update_git_bin_repo ~/nesono-bin

  # check for underlying system
  case ${UNAME} in
    Darwin)
    # Darwin (with home brew)
    check_and_update_homebrew
    ;;
  esac
fi

# check if sudo necessary at all
# Darwin needs fink of macports to be installed
# Linux needs aptitude/apt-get installed
# reset do sudo
do_sudo=0
# check for underlying system
case ${UNAME} in
  Darwin)
    [[ -x $(which port)     ]] && do_sudo=1
  ;;
  Linux)
    [[ -x $(which apt-get)  ]] && do_sudo=1
    [[ -x $(which aptitude) ]] && do_sudo=1
  ;;
esac

# check for user id (must be run as root)
if [ "${do_sudo}" == "1" ]; then
  if [ ${EUID} != 0 ]; then
    echo "remaining script must be run as root! Recalling with sudo"
    sudo $0 --no-bin-check
    exit 0
  fi
else
  exit 0
fi

############ FROM THIS LINE BELOW, ONLY SUDO'D EXECUTED ###########

# check for underlying system
case ${UNAME} in
  Linux)
    # Linux (with aptitude)
    check_and_update_aptget
  ;;

  Darwin)
    # Darwin home brew done above (without sudo)
    # Darwin (with macports)
    check_and_update_macports
    # Mac OS X software update (from command line only)
    mac_software_update_interactive
  ;;
  # End of Darwin
esac

