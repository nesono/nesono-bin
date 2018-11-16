#!/usr/bin/env bash
# interactive script to setup git with useful standard settings
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

echo "*************** GIT SETUP AND GLOBAL CONFIGURATION SCRIPT ***************"
echo ""
echo "Welcome to my custom git setup script for setting, modifying, or removing"
echo "git configuration fields. In the following, you will be asked some questions"
echo "about git configuration settings. Some of them require strings (e.g. your"
echo "username), some require y(es), n(o) or d(elete)."
echo ""
echo "For questions regarding strings, the default value is shown in square"
echo "brackets, e.g. [username] or, if the configuration variable was not set"
echo "before, the square brackets including the default variable are omitted"
echo ""
echo "Questions that shall be answered using y(es), n(o) or d(elete) also have"
echo "square brackets at their end, showing the available options for the setting"
echo "(e.g. [y/N/d]). The default value is printed uppercase."
echo ""
echo "So much for the explanation - don't hesitate to call this script whenever"
echo "you want to modify your settings. Even a single value can be changed"
echo "without much pain as searching the internet for the configuration command."
echo "Enjoy and relax ;)"
echo ""

UNAME=$(uname -s)

function git_set_config_variable_interactive()
{
	NAME=${1}
	INFO=${2}
	# get value from git
	OLDVAL=$(git config --global ${NAME})
	if [ -z "${OLDVAL}" ]; then
		read -e -p "set git cofig option ${NAME}${INFO}: " ANSWER
	else
		read -e -p "set config option ${NAME}${INFO}: [${OLDVAL}] " ANSWER
	fi
	if [ -n "${ANSWER}" ]; then
		git config --global ${NAME} "${ANSWER}"
	fi
}

git_set_config_variable_interactive user.name
git_set_config_variable_interactive user.email
git_set_config_variable_interactive core.editor
git_set_config_variable_interactive merge.tool
git_set_config_variable_interactive diff.tool
git_set_config_variable_interactive difftool.prompt " (true|false)"

if [ ! -e ~/.gitignore ]; then
	echo "The following will setup a global gitignore file for your"
	echo "platform. For instance, under Mac OS X it makes sense to"
	echo "add '.DS_Store' to the global gitignore file..."
	echo ""

	read -e -p "Do you want to create a global gitignore file? [y/N] " ANSWER
	case "${ANSWER}" in
		"y" | "Y" )
			# MAC files
			echo ".DS_Store" >> ~/.gitignore
			# XCode user files
			echo "*.pbxuser"         >> ~/.gitignore
			echo "*.*.perspectivev3" >> ~/.gitignore
			# vim files
			echo "tags"      >> ~/.gitignore
			echo "*.swp"     >> ~/.gitignore
			# Visual Studio user files
			echo "*.user"    >> ~/.gitignore
			echo "*.suo"     >> ~/.gitignore
			echo "*.ncb"
			# doxygen tag files
			echo "*.dox.tag" >> ~/.gitignore
			# GNU/global tag files
			echo GPATH       >> ~/.gitignore
			echo GRTAGS      >> ~/.gitignore
			echo GTAGS       >> ~/.gitignore
			# cscope output
			echo cscope.out  >> ~/.gitignore
			git config --global core.excludesfile ~/.gitignore
	esac
fi

read -e -p "Do you want to enable helper aliases (br, subpull, aliases, etc.)? [y/N/d] " ANSWER
case "${ANSWER}" in
	"y" | "Y" )
		git config --global alias.st status
		git config --global alias.stu "status -uno"
		git config --global alias.ci commit
		git config --global alias.civ "commit -v"
		git config --global alias.co checkout
		git config --global alias.br branch
		git config --global alias.amen "commit -v --amend"
		git config --global alias.subpull "submodule foreach 'git pull'"
		git config --global alias.aliases "config --get-regexp alias"
		git config --global alias.stull "!git stash save && git pull --rebase && git stash pop"
		git config --global alias.adda "add --all"
		git config --global alias.snap "!f() { git push origin HEAD:snap/\`id -u -n\`/\$1; }; f"
		git config --global alias.igate "!f() { git pull --rebase && git push origin HEAD:push/\`id -u -n\`/\$1; }; f"
		git config --global alias.gate "!f() { git pull --rebase && git push origin HEAD:push/rebase/\`id -u -n\`/\$1; }; f"
		git config --global alias.sv "stash show -p"
		git config --global alias.sl "stash list"
		git config --global alias.ss "stash save"
		git config --global alias.sp "stash pop"
		git config --global alias.sd "stash drop"
		git config --global alias.pr "pull --rebase"
		git config --global alias.fa "fetch --all"
		git config --global alias.fap "fetch --all --prune"
		git config --global alias.clobber "clean -d -x -f"
		git config --global alias.sts "status --porcelain"
		git config --global alias.rv "remote -v"
		git config --global alias.root "rev-parse --show-toplevel"
		git config --global alias.fp "fetch --all --prune"
		git config --global alias.pushf "push --force-with-lease"
		git config --global alias.pushn "!f() { git push -u origin \`git rev-parse --abbrev-ref HEAD\`; }; f"
		git config --global alias.up "!f() { git fetch && git rebase && test \"\`git rev-parse --abbrev-ref HEAD\`\" != 'master' && echo 'rebase master' && git rebase origin/master; }; f"
		;;
	"d" | "D" )
		echo "removing section alias from git config"
		git config --global --unset alias.st
		git config --global --unset alias.stu
		git config --global --unset alias.ci
		git config --global --unset alias.civ
		git config --global --unset alias.co
		git config --global --unset alias.br
		git config --global --unset alias.amen
		git config --global --unset alias.subpull
		git config --global --unset alias.aliases
		git config --global --unset alias.stull
		git config --global --unset alias.adda
		git config --global --unset alias.snap
		git config --global --unset alias.igate
		git config --global --unset alias.gate
		git config --global --unset alias.sv
		git config --global --unset alias.sl
		git config --global --unset alias.ss
		git config --global --unset alias.sp
		git config --global --unset alias.sd
		git config --global --unset alias.pr
		git config --global --unset alias.fa
		git config --global --unset alias.fap
		git config --global --unset alias.clobber
		git config --global --unset alias.sts
		git config --global --unset alias.rv
		git config --global --unset alias.root
		git config --global --unset alias.fetchp
		git config --global --unset alias.fp
		git config --global --unset alias.pushf
		git config --global --unset alias.pushn
		git config --global --unset alias.up
		;;
esac

read -e -p "Do you want to enable git log aliases 'glog' and 'flog'? [y/N/d] " ANSWER
case "${ANSWER}" in
	"y" | "Y" )
		git config --global alias.glog "log --pretty=oneline --abbrev-commit --graph --decorate=short"
		git config --global alias.flog "log --pretty=medium --source -p"
		;;
	"d" | "D" )
		echo "removing aliases from git config"
		git config --global --unset alias.glog
		git config --global --unset alias.flog
		;;
esac

read -e -p "Do you want to enable colors for git (branch,diff,interactive,status)? [y/N/d] " ANSWER
case "${ANSWER}" in
	"y" | "Y" )
		git config --global color.branch auto
		git config --global color.diff auto
		git config --global color.interactive auto
		git config --global color.status auto
		;;
	"d" | "D" )
		echo "disabling all color settings"
		git config --global --remove-section color
		;;
esac

read -e -p "Do you want to enable a credential helper for your system to remember passwords? [y/N/d] " ANSWER
case "${ANSWER}" in
	"y" | "Y" )
		case "${UNAME}" in
			Linux )
				if [ -e "/usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring" ]; then
					git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
				else
					echo "git-credential-gnome-keyring not found. Please install and run the script again"
				fi
				;;
			Darwin )
				git config --global credential.helper osxkeychain
				;;
			CYGWIN_* | MINGW32_* )
				if [ -n "$(which git-credential-winstore)" ]; then
					git-credential-winstore
				else
					echo "git-credential-winstore.exe not found. Please install and run the script again"
					echo "the credential helper can be found here:"
					echo "http://gitcredentialstore.codeplex.com/"
				fi
				;;
		esac
		;;
	"d" | "D" )
		git config --global --unset credential.helper 
		;;
esac

exit 0
