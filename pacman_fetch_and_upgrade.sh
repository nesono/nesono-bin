#!/usr/bin/env bash
# helper script to configure 'on_click' for i3status-rust pacman block
echo 'Calling sudo pacman -Syy && sudo pacman -Syu'
sudo pacman -Syy && sudo pacman -Syu
read -p "Script Finished. Press Enter to Quit"
