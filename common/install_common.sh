# include script - not for running

# default disabled colors
col_reset=""
col_sec=""
col_subsec=""
col_change=""
col_info=""
col_error=""

# detect color support and set color codes
if test -t 1; then
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        col_reset="\033[0m"
        col_sec="\033[38;5;69mo  "
        col_subsec="\033[38;5;69moo\033[38;5;69moo "
        col_change="\033[38;5;202mxx "
        col_info="\033[38;5;227mi  "
        col_error="\033[97m\033[41m!! "
    fi
fi

# prefix "o    "; blue foreground, default background"
echo_section() {
    echo -e "$col_sec""$@""$col_reset"
}

# prefix "oooo"; blue foreground, default background
echo_sub_section() {
    echo -e "$col_subsec""$@""$col_reset"
}

# prefix "xx "; red foreground, default background
echo_change() {
    echo -e "$col_change""$@""$col_reset"
}

# prefix "i  "; yellow foreground, default background
echo_info() {
    echo -e "$col_info""$@""$col_reset"
}

# prefix "!! "; red background, white foreground
echo_error() {
    echo -e "$col_error""$@""$col_reset"
}

