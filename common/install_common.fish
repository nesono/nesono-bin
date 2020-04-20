function echo_section
    set_color blue
    echo "o  $argv"
    set_color normal
end

function echo_sub_section
    set_color brblue
    echo "oo $argv"
    set_color normal
end

function echo_change
    set_color brred
    echo "xx $argv"
    set_color normal
end

function echo_info
    set_color bryellow
    echo "i  $argv"
    set_color normal
end

function echo_error
    set_color -o -b red
    set_color white
    echo "!! $argv"
    set_color normal
end
