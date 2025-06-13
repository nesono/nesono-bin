@echo off
REM !/usr/bin/env bash
REM  script to install the nesono-bin package, which
REM  is a set of useful scripts not only for nesono groups developments
REM
REM  Copyright (c) 2012, Jochen Issing <iss@nesono.com>
REM  All rights reserved.
REM
REM  Redistribution and use in source and binary forms, with or without
REM  modification, are permitted provided that the following conditions are met:
REM      * Redistributions of source code must retain the above copyright
REM        notice, this list of conditions and the following disclaimer.
REM      * Redistributions in binary form must reproduce the above copyright
REM        notice, this list of conditions and the following disclaimer in the
REM        documentation and/or other materials provided with the distribution.
REM      * Neither the name of the <organization> nor the
REM        names of its contributors may be used to endorse or promote products
REM        derived from this software without specific prior written permission.
REM
REM  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
REM  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
REM  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
REM  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
REM  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
REM  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
REM  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
REM  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
REM  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
REM  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

echo.
echo     INSTALL nesono-bin (Administrator Access necessary)
echo.

set SCRIPTDIR=%~dp0
echo current script directory
echo %SCRIPTDIR%

cd %HOMEDRIVE%%HOMEPATH%
mklink    .inputrc    %SCRIPTDIR%inputrc
mklink    .vimrc      %SCRIPTDIR%vimrc
mklink    .tmux.conf  %SCRIPTDIR%tmux.conf
mklink    .screenrc   %SCRIPTDIR%screenrc
mklink    .tigrc      %SCRIPTDIR%tigrc
mklink /D .vim        %SCRIPTDIR%vim
mklink    .ackrc      %SCRIPTDIR%ackrc

echo.
exit /B
