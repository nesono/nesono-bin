# include script - not for running

# prefix "o    "; blue foreground, default background"
echo_section() {
    echo -e "\e[38;5;69mo  ""$@""\e[0m"
}

# prefix "oooo"; blue foreground, default background
echo_sub_section() {
    echo -e "\e[38;5;69moo\e[38;5;69moo ""$@""\e[0m"
}

# prefix "xx "; red foreground, default background
echo_change() {
    echo -e "\e[38;5;202mxx ""$@""\e[0m"
}

# prefix "i  "; yellow foreground, default background
echo_info() {
    echo -e "\e[38;5;227mi  ""$@""\e[0m"
}

# prefix "!! "; red background, white foreground
echo_error() {
    echo -e "\e[97m\e[41m!! ""$@""\e[0m"
}

