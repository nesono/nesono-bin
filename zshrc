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

# nesono stuff
export NESONOZSHRC="version 1"
#export LSCOLORS="gxfxcxdxbxegedabagacad"

set -o vi                      # set editor option (vi/emacs)
setopt correct                 # set correction
setopt nobeep                  # disable bothering beep
setopt autolist automenu       # set auto listing to menu style
setopt notify                  # immediately report the status of background options
setopt extended_glob           # enable extended globbing
setopt prompt_subst            # enable prompt substitution
#setopt autopushd               # automatically append dirs to the push/pop list

# setup history
setopt histignorespace         # don't remember lines starting with a ' '
setopt hist_ignore_dups        # ignore duplicates in history
setopt hist_expire_dups_first  # when inserting into history, expire duplicates first
setopt hist_find_no_dups       # when searching in the history, remove duplicates from results
#setopt inc_append_history      # add commands to history file immediately
#setopt share_history           # share history between zsh sessions
setopt extended_history        # add timestamps to history
setopt histverify              # when using ! cmds, confirm first
HISTSIZE=102400
SAVEHIST=102400
HISTFILE=~/.zsh_history

# provide "compose" function, aka digraphs
autoload -Uz insert-composed-char && zle -N insert-composed-char

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

# load simplified color handling ("%K{red}%F{black}")
autoload -U colors && colors

defcol='%{%f%k%}'
## called by zsh before showing the prompt
function precmd()
{
	# set screen title
	settitle zsh "$PWD"

	local usercol fstlineend

	usercol='%{%F{green}%}'
	if [[ "$EUID" == "0" ]]; then
		# root user
		usercol='%{%F{red}%}'
	fi
	fstlineend='%{%f%k%}'
	PROMPT_REPOSITORY_LINE="$(zsh_git_prompt)$(parse_svn_revision)$(parse_hg_branch)"
	PROMPT_TOP_RIGHT="%{%f%k%}𝍄 %D ⌚︎ %* ${usercol}© %M ${fstlineend}"
}


PROMPT=$'$defcol%(?..%{%K{red}%F{white}%} %?)%{$PROMPT_REPOSITORY_LINE %}$PROMPT_TOP_RIGHT\n%{%F{blue}%} %0~%{%F{yellow}%}%{%f%k%}\n%_> '

# provides a temporary session cookie for the shell session
source ${NESONOBININSTALLATIONDIR}/sessioncookie
# provides small helper functions
source ${NESONOBININSTALLATIONDIR}/bashtils/helpers
# defines aliases for all platforms
source ${NESONOBININSTALLATIONDIR}/bashtils/aliases
# source zsh syntax highlighting
[[ -e ${NESONOBININSTALLATIONDIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ${NESONOBININSTALLATIONDIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
  ###################### FREEBSD STUFF ######################################
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

function settitle {
  case $TERM in
    screen )
      # use for GNU/screen
      print -nR $'\033k'$1$'\033'\\
      #print -nR $'\033]0;'$2$''\\
      ;;
    xterm* )
      # Use this one instead for xterms
			print -Pn "\e]0;%~ (%n@%M)\a"
      ;;
  esac
}

# preexec function used by zsh is setting the title as well :)
function preexec
{
    emulate -L zsh
    local -a cmd; cmd=(${(z)1})
    settitle $cmd[1]:t "$cmd[2,-1]"
}

# source prompt status functions
source ${NESONOBININSTALLATIONDIR}/bashtils/ps1status
source ${NESONOBININSTALLATIONDIR}/zshtils/zshgitprompt

# include completion config file
source ${NESONOBININSTALLATIONDIR}/zshtils/completion
# include keybindings (Home/End/Delete/Backspace/...)
source ${NESONOBININSTALLATIONDIR}/zshtils/keybindings
