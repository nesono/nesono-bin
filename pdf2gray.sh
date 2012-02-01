#!/bin/bash
# script to convert a pdf file to grayscale
# needs gostscript (gs)
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

APPNAME=$(basename ${0})

function usage()
{
  echo "usage ${APPNAME}: inputfile.pdf [outputfile.pdf]"
  echo "if output file is omitted, input file is mogrified"
}

# check for required commands
if [ -z "$(which pdf2ps)" ]; then
  echo "pdf2ps not found!"
  echo "is ghostscript installed?"
  exit -1
fi

if [ -z "$(which ps2pdf)" ]; then
  echo "ps2pdf not found!"
  echo "is ghostscript installed?"
  exit -1
fi

case "${1}" in
  "-h" | "--help" )
  usage
  exit 0
  ;;
esac

if [ ! -r "${1}" ]; then
  echo "input file ${1} not found!"
  usage
  exit -2
fi

if [ ${#@} -gt 2 ]; then
  echo "too many parameters found!"
  usage
  exit -3
fi

tmpps=$(tempfile)
if [ ${#@} -eq 1 ]; then
  output=${1}
else
  output=${2}
fi

pdf2ps -sDEVICE=psgray ${1} ${tmpps}
ps2pdf ${tmpps} ${output}
rm -f ${tmpps}
