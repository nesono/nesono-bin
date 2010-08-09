export NESONOZSHRC="version 1"
export NESONOBININSTDIR="${HOME}/nesono-bin"
export LSCOLORS="gxfxcxdxbxegedabagacad"

# set emacs editor option
set -o emacs
# set correction
setopt correct
# disable bothering beep
setopt no_beep
# set auto listing to menu style
setopt autolist automenu
# immediately report the status of background options
setopt notify
# enable extended globbing
setopt extended_glob
# enable prompt substitution
setopt prompt_subst

# setup history
HISTSIZE=3000
SAVEHIST=3000
HISTFILE=~/.zsh_history

setopt histignorespace
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt append_history
setopt share_history
setopt extended_history

# load simplified color handling ("$bg[red]$fg[black]")
autoload -U colors && colors

## configure precmd prompt preparation
#precmd ()
#{
#}

# provides small helper functions
source ${NESONOBININSTDIR}/bashtils/helpers
# provides the file/dir transfer stack with pusht/popt/transfers
#source ${NESONOBININSTDIR}/bashtils/transferstack
# defines aliases for all platforms
source ${NESONOBININSTDIR}/bashtils/aliases

uname=$(uname -s)

case ${uname} in
  Darwin)
  ###################### DARWIN STUFF ######################################
  source ${NESONOBININSTDIR}/bashtils/aliases.darwin
  #source ${NESONOBININSTDIR}/bashtils/rm2trash.darwin
  source ${NESONOBININSTDIR}/bashtils/defines.darwin
  ;;

  Linux)
  ###################### LINUX STUFF ######################################
  source ${NESONOBININSTDIR}/bashtils/aliases.linux
  #source ${NESONOBININSTDIR}/bashtils/rm2trash.linux
  source ${NESONOBININSTDIR}/bashtils/defines.linux
  ;;
esac

source ${NESONOBININSTDIR}/bashtils/ps1status

# source zsh specific files
source ${NESONOBININSTDIR}/zshtils/completion
source ${NESONOBININSTDIR}/zshtils/keybindings

PROMPT='%{$fg_bold[green]%}%m:%{$fg_bold[blue]%}%c%{$fg_bold[yellow]%}%{$(parse_git_branch)$(parse_svn_revision)%}%{$reset_color%} '

