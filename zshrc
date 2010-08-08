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

# load vcs_info (git/svn/cvs information)
autoload -Uz vcs_info
# vcs_info
zstyle ':vcs_info:*' disable hg bzr cdv darcs mtn svk tla

# configure precmd prompt preparation
precmd () {
}

source ${NESONOBININSTDIR}/zshtils/completion
source ${NESONOBININSTDIR}/zshtils/keybindings

#PROMPT="%(?..%{$fg_bold[red]%}%?%{$reset_color%} )%1(!.%{$fg_bold[red]%}.%{$fg_bold[blue]%})%n%{$reset_color%} %{$fg_bold[white]%}%25<..<%~%<<%{$reset_color%} ${vcs_info_msg_0_}%f%# "
#SPROMPT="%{$fg_bold[red]%}zsh%{$reset_color%}: correct %{$fg_bold[white]%}%R%{$reset_color%} to %{$fg_bold[white]%}%r%{$reset_color%}? (ynea): "
#RPROMPT="%(?..%{$fg_bold[red]%}:(%{$reset_color%}) %1(j.%{$fg[green]%}[%j]%{$reset_color%}.)"

