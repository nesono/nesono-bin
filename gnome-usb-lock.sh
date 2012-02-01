#!/bin/bash
#
# script to use an USB key as your desktop key.
# Run this script with cron as the same user as the desktop session
# every minute, e.g. using the following line:
#*  *  *  *  * ~/nesono-bin/gnome-usb-lock.sh > /dev/null 2>&1
#
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

# Replace with the ID of your USB device
# Example: id="ID 05ac:1292 Apple, Inc"
#id="ID 0bb4:0c02 High Tech Computer Corp.
# save ID in a config file ${HOME}/.usb-key
if [ -e ~/.usb-key ] ; then
  . ~/.usb-key
fi

# check for notify-send
NOTIFYSENDBIN=$(which notify-send)
if [ -z "${NOTIFYSENDBIN}" ]; then
  echo "Notify send not found, optional anyways."
  echo "If you want notification dialogs however,"
  echo "install it e.g. by invoking:"
  echo "aptitude install libnotify-bin"
fi
# check for sox' play
PLAYBIN=$(which play)

# runs every 2 seconds
for ((i=0; i<=28; i++)); do
  # useful for debugging
  #echo "Screen saver query:"
  #gnome-screensaver-command --query
  #echo ""

  if [ -z "$(lsusb | grep "$id")" ]
  then
    echo "Key is NOT plugged in"

    if [ -n "$(DISPLAY=:0 gnome-screensaver-command --query | grep "is active")" ]
    then
      # stop locking the screen
      rm -f /tmp/autoUnlock.lock
    elif [ -e /tmp/autoUnlock.lock ]
    then
      if [ -n "${NOTIFYSENDBIN}" ]; then
        DISPLAY=:0 notify-send -t 1000 --icon=dialog-info "Key Disconnected" "Bye Bye!"
        sleep 1
      fi

      # lock the desktop
      DISPLAY=:0 gnome-screensaver-command --lock
      if [ -n "${PLAYBIN}" ]; then
        play /usr/share/sounds/gnome/default/alerts/bark.ogg
      fi
      rm /tmp/autoUnlock.lock
  fi
  else
    echo "Key IS plugged in"
    if [ ! -e /tmp/autoUnlock.lock ]
    then
      DISPLAY=:0 gnome-screensaver-command --deactivate
      if [ -n "${PLAYBIN}" ]; then
        play /usr/share/sounds/gnome/default/alerts/glass.ogg
      fi
      if [ -n "${NOTIFYSENDBIN}" ]; then
        DISPLAY=:0 notify-send -t 5000 --icon=dialog-info "Key Authenticated" "Welcome Back ${USER}!"
      fi
      # create lock file - indicates, whether to lock next time key is unplugged
      touch /tmp/autoUnlock.lock
    else
      ##### These lines don't work, as the screen cannot be asked, if the screen
      ##### is locked or just the screensaver is active - not for users, which
      ##### distinct between screensaver and screen locking

      # Uncomment the 3 following lines if you would like your computer to remind
      # you if you lock your screen without disconnecting the device
      if [ -n "$(DISPLAY=:0 gnome-screensaver-command --query | grep "is active")" ]
      then
        echo "Don't forget the key!" > /tmp/gnomeUsbLockReminder
        DISPLAY=:0 festival --tts /tmp/gnomeUsbLockReminder
        rm /tmp/gnomeUsbLockReminder
      fi
    fi
  fi
  sleep 2
done
