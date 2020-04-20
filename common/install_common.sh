# include script - not for running
echo_section() {
    echo -e "\e[38;5;69mo  ""$@""\e[0m"
}

echo_sub_section() {
    echo -e "\e[38;5;69moo ""$@""\e[0m"
}

echo_change() {
    echo -e "\e[38;5;202mxx ""$@""\e[0m"
}

echo_info() {
    echo -e "\e[38;5;227mi  ""$@""\e[0m"
}

echo_error() {
    echo -e "\e[97m\e[41m!! ""$@""\e[0m"
}

