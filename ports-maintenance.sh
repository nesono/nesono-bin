#!/bin/bash
# script for daily maintenance of mac ports
# upgrades to packages
# discards orphaned packages, etc.

# check for user id (must be run as root)
if [ ${EUID} != 0 ]; then
  echo "script must be run as root! Recalling with sudo"
  sudo $0
  exit 0
fi

if [ -n $(which port) ]; then
  echo "port available"

  read -p "Shall I do selfupgrade? [y/N] " ANSWER

  case ${ANSWER} in
    "y" | "Y" )
      echo "running port selfupdate"
      # upgrade system
      port -c selfupdate
      ;;
  esac

  # show outdated ports
  OUTDATED=$(port outdated | grep -v 'No installed ports are outdated.')

  if [ -n "${OUTDATED}" ]; then
    read -p "Shall I oupgrade the outdated ports? [Y/n] " ANSWER
    case ${ANSWER} in
      "" | "y" | "Y" )
        # upgrade system
        port upgrade outdated
        ;;
    esac
  else
    echo "no ports outdated"
    echo "exiting"
  fi

else
  echo "port not installed"
fi
