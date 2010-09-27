# nesono stuff
export NESONOZSHRC="version 1"
export NESONOBININSTDIR="${HOME}/nesono-bin"
#export LSCOLORS="gxfxcxdxbxegedabagacad"

set -o emacs                   # set emacs editor option
setopt correct                 # set correction
setopt nobeep                  # disable bothering beep
setopt autolist automenu       # set auto listing to menu style
setopt notify                  # immediately report the status of background options
setopt extended_glob           # enable extended globbing
setopt prompt_subst            # enable prompt substitution

# setup history
setopt histignorespace         # don't remember lines starting with a ' '
setopt hist_ignore_dups        # ignore duplicates in history
setopt hist_expire_dups_first  # when inserting into history, expire duplicates first
setopt hist_find_no_dups       # when searching in the history, remove duplicates from results
setopt inc_append_history      # add commands to history file immediately
setopt share_history           # share history between zsh sessions
setopt extended_history        # add timestamps to history
setopt histverify              # when using ! cmds, confirm first
HISTSIZE=102400
SAVEHIST=102400
HISTFILE=~/.zsh_history

# provide "compose" function, aka digraphs
autoload -Uz insert-composed-char && zle -N insert-composed-char

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

# load simplified color handling ("$bg[red]$fg[black]")
autoload -U colors && colors

if [[ $TERM == "screen" ]]; then
  if [[ "$EUID" == "0" ]]; then
    # root user
    PROMPT='%{$fg_bold[red]%}>%{$reset_color%} '
  else
    # normal users
    PROMPT='%{$fg_bold[green]%}>%{$reset_color%} '
  fi
else
  if [[ "$EUID" == "0" ]]; then
    # root user
    PROMPT='%{$fg_bold[red]%}%m:%{$fg_bold[blue]%}%c%{$fg_bold[yellow]%}%{$(parse_git_branch)$(parse_svn_revision)%}%{$reset_color%} '
  else
    # normal users
    PROMPT='%{$fg_bold[green]%}%m:%{$fg_bold[blue]%}%c%{$fg_bold[yellow]%}%{$(parse_git_branch)$(parse_svn_revision)%}%{$reset_color%} '
  fi
fi

# provides small helper functions
source ${NESONOBININSTDIR}/bashtils/helpers
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

# source prompt status functions
source ${NESONOBININSTDIR}/bashtils/ps1status
if [[ $TERM == "screen" ]]; then
  ## called by zsh before showing the prompt
  function precmd()
  {
    # set the current working directory
    set_screen_path
  }
fi

# include completion config file
source ${NESONOBININSTDIR}/zshtils/completion
# include keybindings (Home/End/Delete/Backspace/...)
source ${NESONOBININSTDIR}/zshtils/keybindings
# provides the file/dir transfer stack with pusht/popt/transfers
source ${NESONOBININSTDIR}/zshtils/transferstack
