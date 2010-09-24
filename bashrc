# to indicate, that nesono-bin was included in ~/.profile
export NESONOBASHRC="version 1"
export NESONOBININSTDIR="${HOME}/nesono-bin"

# set the terminal colors to use lighter blue for directories
# (only change is first character to be 'E' instead of 'e'
# original:
#export LSCOLORS="exfxcxdxbxegedabagacad"
# modified:
export LSCOLORS="gxfxcxdxbxegedabagacad"

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
  PS1='> '
else
  if [[ "$EUID" == "0" ]]; then
    # root user
    PS1='\[\033[31m\]\h:\[\033[1;34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
  else
    # normal users
    PS1='\[\033[1;32m\]\h:\[\033[1;34m\]\W\[\033[33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[0m\] '
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
