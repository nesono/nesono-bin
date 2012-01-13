#!/bin/bash
# interactive script to setup git with useful standard settings

echo "*************** GIT SETUP AND GLOBAL CONFIGURATION SCRIPT ***************"
echo ""
echo "Welcome to my custom git setup script for setting, modifying, or removing"
echo "git configuration fields. In the following, you will be asked some questions"
echo "about git configuration settings. Some of them require strings (e.g. your"
echo "username), some require y(es), n(o) or d(elete)."
echo ""
echo "For questions regarding strings, the default value is shown in square"
echo "brackets, e.g. [username] or, if the configuration variable was not set"
echo "before, the square brackets including the default variable are omitted"
echo ""
echo "Questions that shall be answered using y(es), n(o) or d(elete) also have"
echo "square brackets at their end, showing the available options for the setting"
echo "(e.g. [y/N/d]). The default value is printed uppercase."
echo ""
echo "So much for the explanation - don't hesitate to call this script whenever"
echo "you want to modify your settings. Even a single value can be changed"
echo "without much pain as searching the internet for the configuration command."
echo "Enjoy and relax ;)"
echo ""

UNAME=$(uname -s)

case "${UNAME}" in
  "Linux" )
    if [ -n "$(which aptitude)" ]; then
      INSTALL_GIT="sudo aptitude install git git-svn git-gui"
    fi
    ;;
  "Darwin" )
    if [ -n "$(which port)" ]; then
      if [ -n "$(which fink)" ]; then
        echo "mac ports AND fink found on you PC"
        echo "preferring mac ports"
      fi
      INSTALL_GIT="sudo port install git-core +svn +bash_completion"
    fi
    if [ -n "$(which fink)" ]; then
      INSTALL_GIT="fink install git git-svn"
    fi
    ;;
esac

# check, if user needs to install git first
if [ -z "$(which git)" ]; then
  echo "git not installed!"
  read -e -p "Shall I try to install for you? [y/N] " ANSWER

  case "${ANSWER}" in
    "y" | "Y" )
    if [ -n "${INSTALL_GIT}" ]; then
      echo "installing git..."
      ${INSTALL_GIT}
      echo "... installatin finished"
    else
      echo "can not install git"
      echo "unknown system or missing"
      echo "mac ports or fink..."
    fi
  esac
fi

# function to set a config variable of git
# interactively $1: name $2 value
function git_set_config_variable_interactive()
{
  NAME=${1}
  # get value from git
  OLDVAL=$(git config --global ${NAME})
  if [ -z "${OLDVAL}" ]; then
    read -e -p "set git cofig option ${NAME}: " ANSWER
  else
    read -e -p "set config option ${NAME}: [${OLDVAL}] " ANSWER
  fi
  if [ -n "${ANSWER}" ]; then
    git config --global ${NAME} "${ANSWER}"
  fi
}

git_set_config_variable_interactive user.name
git_set_config_variable_interactive user.email
git_set_config_variable_interactive core.editor
git_set_config_variable_interactive merge.tool

if [ ! -e ~/.gitignore ]; then
  echo "The following will setup a global gitignore file for your"
  echo "platform. For instance, under Mac OS X it makes sense to"
  echo "add '.DS_Store' to the global gitignore file..."
  echo ""

  read -e -p "Do you want to create a global gitignore file? [y/N] " ANSWER
  case "${ANSWER}" in
    "y" | "Y" )
    # MAC files
    echo ".DS_Store" >> ~/.gitignore
    # XCode user files
    echo "*.pbxuser"         >> ~/.gitignore
    echo "*.*.perspectivev3" >> ~/.gitignore
    # vim files
    echo "tags"      >> ~/.gitignore
    echo "*.swp"     >> ~/.gitignore
    # Visual Studio user files
    echo "*.user"    >> ~/.gitignore
    echo "*.suo"     >> ~/.gitignore
    echo "*.ncb"
    # doxygen tag files
    echo "*.dox.tag" >> ~/.gitignore
    git config --global core.excludesfile ~/.gitignore
  esac
fi

# check if svn like config options shall be set
read -e -p "Do you want to enable svn like aliases (st,stu,ci,co,br)? [y/N/d] " ANSWER
case "${ANSWER}" in
  "y" | "Y" )
    git config --global alias.st status
    git config --global alias.stu "status -uno"
    git config --global alias.ci commit
    git config --global alias.civ "commit -v"
    git config --global alias.co checkout
    git config --global alias.br branch
  ;;
  "d" | "D" )
    echo "removing section alias from git config"
    git config --global --unset alias.st
    git config --global --unset alias.stu
    git config --global --unset alias.ci
    git config --global --unset alias.civ
    git config --global --unset alias.co
    git config --global --unset alias.br
  ;;
esac

# check if graphlog alias shall be enabled
read -e -p "Do you want to enable git log alias 'graphlog'? [y/N/d] " ANSWER
case "${ANSWER}" in
  "y" | "Y" )
    git config --global alias.graphlog "log --pretty=oneline --abbrev-commit --graph"
  ;;
  "d" | "D" )
    echo "removing section alias from git config"
    git config --global --unset alias.graphlog
  ;;
esac

# check if color config options shall be set
read -e -p "Do you want to enable colors for git (branch,diff,interactive,status)? [y/N/d] " ANSWER
case "${ANSWER}" in
  "y" | "Y" )
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.interactive auto
    git config --global color.status auto
  ;;
  "d" | "D" )
    echo "disabling all color settings"
    git config --global --remove-section color
  ;;
esac

# ask for and setup github
read -e -p "Do you want to setup a github account? [y/N/d] " ANSWER
case "${ANSWER}" in
  "y" | "Y" )
    git_set_config_variable_interactive github.user
    git_set_config_variable_interactive github.token
  ;;
  "d" | "D" )
    echo "removing section github from global git config"
    git config --global --remove-section github
  ;;
esac

exit 0
