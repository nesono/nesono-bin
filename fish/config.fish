set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red
set __fish_git_prompt_showcolorhints 'yes'

# Status Chars
set __fish_git_prompt_char_upstream_prefix ''
set __fish_git_prompt_char_upstream_ahead  '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_stateseparator  '|'
set __fish_git_prompt_char_dirtystate      '✚'
set __fish_git_prompt_char_invalidstate    '✖'
set __fish_git_prompt_char_stagedstate     '●'
set __fish_git_prompt_char_untrackedfiles  '…'
set __fish_git_prompt_char_cleanstate      '✔'
set __fish_git_prompt_char_stashstate      '↩'
#set __fish_git_prompt_describe_style 'branch'

function fish_prompt
  set -l last_status $status

  printf '%s' (echo '>')

  if not test $last_status -eq 0
    set_color $fish_color_error
    #printf '%d' ($last_status)
    set_color normal
  end
  set_color -b grey
  printf '%s ' (__fish_git_prompt)
  printf '%s ' (date "+%y-%m-%d %H:%M:%S")
  set_color green
  printf  '%s\n' (hostname)

  set_color $fish_color_cwd
  printf '%s\nλ ' (prompt_pwd)

  set_color normal
end
