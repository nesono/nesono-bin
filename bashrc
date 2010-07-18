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
