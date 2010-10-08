#!/bin/bash
# script to convert a pdf file to grayscale
# needs gostscript (gs)

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
