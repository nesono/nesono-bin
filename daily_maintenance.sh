#!/usr/bin/env bash
# script for daily maintenance of the server
# upgrades to packages
# discards orphaned packages, etc.
#
# Copyright (c) 2012, Jochen Issing <iss@nesono.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the
#   names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
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

#set -e

# get system uname
UNAME=$(uname -s)

function check_and_update_svn_bin_repo()
{
	local DIR="${1}"

	if [ ! -d "${DIR}" ]; then
		echo "skipping: ${DIR}"
		return
	else
		pushd "${DIR}" &> /dev/null
		echo "### checking if svn repo: ${DIR}"

		local REV=$(svn info 2>/dev/null | grep Revision | sed -e 's/Revision: //')
		[ "$REV" ] || return

		echo "### checking for svn repo: ${DIR}"

		svn st -u &> /dev/null
		if [ ! $? == 0 ]; then echo "### Can not access repository! Stopping update"; echo ''; return; fi

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
	local DIR="${1}"

	if [ ! -d "${DIR}" ]; then
		echo "skipping: ${DIR}"
		return
	else
		pushd "${DIR}" &> /dev/null
		echo "### checking if git repo: ${DIR}"

		STATUS=$(git status --porcelain 2>/dev/null)
		[ $? -eq 128 ] && return

		REMOTEUP=1

		git fetch origin &> /dev/null
		if [ ! $? == 0 ]; then REMOTEUP=0; fi

		echo "### checking for git repo: ${DIR}"
		if [ -n $(git remote | grep -e '^origin') ]; then
			if [ ${REMOTEUP} == 0 ]; then
				echo "### Can not access depot! Skipping rebase"
			else
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

		git submodule update --init

		popd &> /dev/null
		echo ""
	fi
}

function check_and_update_homebrew()
{
	if [ -x "$(which brew)" ]; then
		echo "### brew available"

		echo "### running brew update"
		brew update

		OUTDATED=$(brew outdated)

		if [ -n "${OUTDATED}" ]; then
			read -e -p "Shall I upgrade the outdated formulas? [Y/n] " ANSWER
			case ${ANSWER} in
				"" | "y" | "Y" )
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
	if [ -x "$(which port)" ]; then
		echo "### port available"

		echo "### running port selfupdate"
		port -c selfupdate

		OUTDATED=$(port list outdated)

		if [ -n "${OUTDATED}" ]; then
			read -e -p "Shall I upgrade the outdated ports? [Y/n] " ANSWER
			case ${ANSWER} in
				"" | "y" | "Y" )
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
	read -e -p "Shall I check for apple softwareupdate? [y/N] " ANSWER

	case ${ANSWER} in
		"y" | "Y" )
			TMPSTDOUT=/tmp/daily_maintenance.stdout.tmp
			TMPSTDERR=/tmp/daily_maintenance.stderr.tmp

			echo "getting list of available upgrades"
			softwareupdate -l > ${TMPSTDOUT} 2> ${TMPSTDERR}
			if [ -z "$(cat ${TMPSTDERR})" ]; then
				cat ${TMPSTDOUT}
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

	apt-get autoremove

	echo "autocleaning repository"
	apt-get autoclean

	echo ""
}

function check_and_update_ports()
{
	echo "Portsnap fetch and update"
	portsnap fetch update && portmaster -L --index-only| egrep '(ew|ort) version|total install'
	echo -n "Last update: "
	date -r `pkg query %t | sort | tail -n1` "+%Y%m%d"

	portmaster -a -d
	portmaster -y --clean-packages
	# do some statistic tricks - rand(256) < 20
	if [ `od -An -N1 -i /dev/random` -lt 20 ]; then
		portmaster -y -t --clean-distfiles
	else
		portmaster -y --clean-distfiles
	fi
}

function freebsd_update()
{
	echo "updating FreeBSD binary land - if anything goes wrong call:"
	echo "freebsd-update rollback"
	read -n1 -r -s -p "Press any key to continue" key
	freebsd-update fetch
	freebsd-update install
}

function freebsd_documentation_update()
{
	check_and_update_svn_bin_repo /usr/doc
	#pushd /usr/doc/en_US.ISO8859-1
	#make install clean
	#popd
}

function update_ez_jail()
{
	echo "EZ Jail ports update"
	ezjail-admin update -Pp
}

function check_and_update_drush()
{
	if [ -x "$(which drush)" ]; then
		echo "updating /var/www with drush"
		drush -r /var/www pm-update
	fi
	if [ -n "$(jls | grep www.nesono.com)" ]; then
		echo www.nesono.com jail found - checking for drupal updates
		jexec 1 drush -r /usr/local/www/apache24/data/ pm-update
	fi
}

function run_in_tmux()
{
	local name='daily maintenance'
	if [[ ! -x $(which tmux) ]]; then
		echo "tmux not installed, continuing"
		return 
	fi
	if [[ -n $(tmux ls | grep "$name") ]]; then
		echo "tmux session with name $name already running"
		return
	else
		echo "restarting in tmux"
		tmux new -s "$name" "export NESONOBININSTALLATIONDIR=${NESONOBININSTALLATIONDIR} && export STOP_TMUX=1 && $0"
		exit 0
	fi
}

if [ "$1" != "--after-su" ]; then
	run_in_tmux
	check_and_update_svn_bin_repo ${NESONOBININSTALLATIONDIR}
	check_and_update_git_bin_repo ${NESONOBININSTALLATIONDIR}

	case ${UNAME} in
		Darwin)
		check_and_update_homebrew
		;;
	esac
fi

# check if sudo necessary at all
do_sudo=0
case ${UNAME} in
	Darwin)
		[[ -x "$(which port)"		 ]] && do_sudo=1
	;;
	Linux)
		[[ -x $(which apt-get)	]] && do_sudo=1
		[[ -x $(which aptitude) ]] && do_sudo=1
		[[ -x $(which drush)    ]] && do_sudo=1
	;;
	FreeBSD)
		[[ -x $(which portsnap) ]] && do_sudo=1
		[[ -n "$(jls | grep www.nesono.com)" ]] && do_sudo=1
	;;
esac

# apply sudo
if [ "${do_sudo}" == "1" ]; then
	if [ ${EUID} != 0 ]; then
		echo "remaining script must be run as root! Recalling with sudo"
		echo "calling $0"
		sudo $0 --after-su
		exit 0
	fi

	# check for underlying system
	case ${UNAME} in
		Linux)
			check_and_update_aptget
			check_and_update_drush
			;;

		Darwin)
			# Darwin home brew done above (without sudo)
			check_and_update_macports
			mac_software_update_interactive
			;;

		FreeBSD)
			check_and_update_ports
			update_ez_jail
			freebsd_update
			freebsd_documentation_update
			check_and_update_drush
			;;
	esac
fi

echo "End of Script"
read -n1 -r -s -p "Press any key to finish" key
