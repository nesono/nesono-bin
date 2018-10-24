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

# to indicate, that nesono-bin was included in ~/.profile
export NESONOBASHRC="version 1"

# set the terminal colors to use lighter blue for directories
# (only change is first character to be 'E' instead of 'e'
# original:
#export LSCOLORS="exfxcxdxbxegedabagacad"
# modified:
#export LSCOLORS="gxfxcxdxbxegedabagacad"

# provides a temporary session cookie for the shell session
source ${NESONOBININSTALLATIONDIR}/sessioncookie
# provides small helper functions
source ${NESONOBININSTALLATIONDIR}/bashtils/helpers
# defines aliases for all platforms
source ${NESONOBININSTALLATIONDIR}/bashtils/aliases

# add one of these lines to your ~/.bashrc for git/svn status display in bash prompt with colors
PROMPT_MODE="normal"
if [[ "$EUID" == "0" || "${USER##*-}" == "a"  ]]; then
    PROMPT_MODE="admin"
fi
if [ -n "$TEST_WORKSPACE" ] || [ -n "$WORKSPACE_DIR" ]; then
    PROMPT_MODE="docker"
fi

case $PROMPT_MODE in 
    normal)
        PS1='\[\033[32m\]\h:\[\033[34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
        ;;
    admin)
        PS1='\[\033[31m\]\h:\[\033[34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
        ;;
    docker)
        PS1='\[\033[33m\]docker\[\033[32m\]@\h:\[\033[34m\]\W\[\033[0m\] '
        ;;
esac

uname=$(uname -s)

case ${uname} in
  Darwin)
  ###################### DARWIN STUFF ######################################
  source ${NESONOBININSTALLATIONDIR}/bashtils/aliases.darwin
  source ${NESONOBININSTALLATIONDIR}/bashtils/rm2trash.darwin
  source ${NESONOBININSTALLATIONDIR}/bashtils/defines.darwin
  ;;

  Linux)
  ###################### LINUX STUFF ######################################
  source ${NESONOBININSTALLATIONDIR}/bashtils/aliases.linux
  source ${NESONOBININSTALLATIONDIR}/bashtils/rm2trash.linux
  source ${NESONOBININSTALLATIONDIR}/bashtils/defines.linux
  ;;
  FreeBSD)
  ##################### FREEBSD STUFF #####################################
  source ${NESONOBININSTALLATIONDIR}/bashtils/aliases.freebsd
  source ${NESONOBININSTALLATIONDIR}/bashtils/rm2trash.freebsd
  source ${NESONOBININSTALLATIONDIR}/bashtils/defines.freebsd
	;;
  CYGWIN_*)
  ###################### CYGWIN STUFF ######################################
  source ${NESONOBININSTALLATIONDIR}/bashtils/aliases.cygwin
  source ${NESONOBININSTALLATIONDIR}/bashtils/rm2trash.cygwin
  source ${NESONOBININSTALLATIONDIR}/bashtils/defines.cygwin
	;;
  MINGW32_*)
  ###################### MINGW STUFF ######################################
  source ${NESONOBININSTALLATIONDIR}/bashtils/aliases.mingw
  source ${NESONOBININSTALLATIONDIR}/bashtils/rm2trash.mingw
  source ${NESONOBININSTALLATIONDIR}/bashtils/defines.mingw
	;;
esac

source ${NESONOBININSTALLATIONDIR}/bashtils/ps1status

case ${uname} in
  CYGWIN_* | MINGW32_*)
	# disable repo prompt entry on cygwin
	ps1repo off
  ;;
esac
