export NESONOBASHRC="version 1"
export NESONOBININSTDIR="${HOME}/nesono-bin"

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
setopt histignorespace
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt append_history
setopt share_history
setopt extended_history

# load simplified color handling ("$bg[red]$fg[black]")
autoload -U colors && colors

# configure precmd prompt preparation
precmd ()
{
}

source ${NESONOBININSTDIR}/zshtils/completion
source ${NESONOBININSTDIR}/zshtils/keybindings
source ${NESONOBININSTDIR}/bashtils/ps1status

PROMPT='%{$fg_bold[green]%}%m:%{$fg_bold[blue]%}%c%{$fg_bold[yellow]%}%{$(parse_git_branch)$(parse_svn_revision)%}%{$reset_color%} '

