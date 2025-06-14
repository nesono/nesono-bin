#!/usr/bin/env bash


assert_executable() {
    local executable=$1
    if [ ! -x "$(which "$executable" 2> /dev/null)" ]; then
        notify-send "$executable not installed, aborting screenshot"
    fi
}

assert_executable hacksaw
assert_executable shotgun
assert_executable xclip

MODE="full"
while getopts ":t" opt; do
  case ${opt} in
    t )
        MODE="tile"
      ;;
	* )
	  echo "Invalid option: -$OPTARG" >&2
	  exit 1
	  ;;
  esac
done

if [ "$MODE" == "tile" ]; then
    shotgun -f png -g "$(hacksaw)" - | xclip -t 'image/png' -selection clipboard
else
    shotgun -f png - | xclip -t 'image/png' -selection clipboard
fi
