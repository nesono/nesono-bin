#!/usr/bin/env python
# script to convert a binary file into a C/C++ header

from optparse import OptionParser
from random import randint
import re

parser = OptionParser()
parser.add_option("-i", "--input", dest="inputfilename",
                  help="input file name")
parser.add_option("-o", "--output",
                  dest="outputfilename",
                  help="output file name")

(options, args) = parser.parse_args()
salt = randint(0,1000)

nonkeyword = ['_', ',.;%#']

dataname = re.sub("[%s]" % "".join(nonkeyword), "_",  options.outputfilename)
tag = dataname + "_" + str(salt)

try:
	infile = open(options.inputfilename, "rb")
	outfile = open(options.outputfilename, "wb")
	indata = infile.read()

	outfile.write("#ifndef " + tag + "\n")
	outfile.write("#define " + tag + " " + tag + "\n" + "\n")

	outfile.write("const unsigned char " + dataname + " = { " + "\n")
	outfile.write( ", ".join(hex(ord(n)) for n in indata) )
	outfile.write("}" + "\n")
	outfile.write("#endif" + "\n")

finally:
	infile.close()
	outfile.close()

