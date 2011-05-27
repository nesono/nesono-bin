#!/bin/bash
# script to call repository status functions in screen's backtick

. ${NESONOBININSTDIR}/bashtils/ps1status

echo "$(parse_git_branch)$(parse_svn_revision)"
