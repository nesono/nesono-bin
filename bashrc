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
export NESONOBININSTDIR="${HOME}/nesono-bin"

# set the terminal colors to use lighter blue for directories
# (only change is first character to be 'E' instead of 'e'
# original:
#export LSCOLORS="exfxcxdxbxegedabagacad"
# modified:
#export LSCOLORS="gxfxcxdxbxegedabagacad"

# provides small helper functions
source ${NESONOBININSTDIR}/bashtils/helpers
# provides the file/dir transfer stack with pusht/popt/transfers
source ${NESONOBININSTDIR}/bashtils/transferstack
# defines aliases for all platforms
source ${NESONOBININSTDIR}/bashtils/aliases

#
# add one of these lines to your ~/.bashrc for git/svn status display in bash prompt with colors
if [[ $TERM == "screen" ]]; then
  PROMPT_COMMAND=set_screen_path
  # set simple prompt
  if [[ "$EUID" == "0" ]]; then
    # root user
    PS1='\[\033[31m\]>\[\033[0m\] '
  else
    # normal users
    PS1='\[\033[32m\]>\[\033[0m\] '
  fi
else
  if [[ "$EUID" == "0" ]]; then
    # root user
    PS1='\[\033[31m\]\h:\[\033[34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
  else
    # normal users
    PS1='\[\033[32m\]\h:\[\033[34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
  fi
fi

uname=$(uname -s)

case ${uname} in
  Darwin)
  ###################### DARWIN STUFF ######################################
  source ${NESONOBININSTDIR}/bashtils/aliases.darwin
  source ${NESONOBININSTDIR}/bashtils/rm2trash.darwin
  source ${NESONOBININSTDIR}/bashtils/defines.darwin
  ;;

  Linux)
  ###################### LINUX STUFF ######################################
  source ${NESONOBININSTDIR}/bashtils/aliases.linux
  source ${NESONOBININSTDIR}/bashtils/rm2trash.linux
  source ${NESONOBININSTDIR}/bashtils/defines.linux
  ;;
esac

source ${NESONOBININSTDIR}/bashtils/ps1status
