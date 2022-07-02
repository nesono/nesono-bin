#!/usr/bin/env bash

echo "Polybar launching at $(date)" >> ~/.polybar_launch.log

readonly polybar_bin=polybar

# Terminate any currently running instances
killall -q $polybar_bin

# Pause while killall completes
while pgrep -u $UID -x $polybar_bin > /dev/null; do sleep 1; done

if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m $polybar_bin --reload top -c ~/.config/polybar/config &
  done
else
  $polybar_bin --reload top -c ~/.config/polybar/config &
fi


# fallback to i3bar if polybar does not start
if [ -z "$(pgrep $polybar_bin)" ]; then
    echo "Polybar ($polybar_bin) not found using pgrep: $(pgrep $polybar_bin)" >> ~/.polybar_launch.log
    i3bar
fi
