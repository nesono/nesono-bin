#!/usr/bin/env python
# script to convert a binary file into a C/C++ header

# BSD LICENSE
#
# Copyright (c) 2014, Jochen Issing <iss@nesono.com>
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

from random import randint
import re
import sys
import os


def usage(scriptname):
    print("usage: %s infile outfile" % (scriptname))


def hexformat(data, counter):
    hexdata = str(hex(ord(data)))
    if(counter % 16 == 0):
        return "\n    " + hexdata
    else:
        return hexdata


scriptname = os.path.basename(sys.argv[0])
if len(sys.argv) < 3:
    usage(scriptname)
    sys.exit(-1)

infilename = sys.argv[1]
outfilename = sys.argv[2]
args = [scriptname, infilename, outfilename]

nonkeyword = ['_', ',.;%#']

dataname = re.sub("[%s]" % "".join(nonkeyword), "_",  outfilename)
tag = dataname

try:
    infile = open(infilename, "rb")
    outfile = open(outfilename, "wb")
    indata = infile.read()

    outfile.write("/* AUTOMATICALLY GENERATED FILE DO NOT EDIT */\n")
    outfile.write("/* Generated with: %s */\n\n" % " ".join(args))

    outfile.write("#ifndef " + tag + "\n")
    outfile.write("#define " + tag + " " + tag + "\n" + "\n")

    outfile.write("const unsigned char " + dataname + "[] = { ")
    outfile.write(", ".join(hexformat(n, i) for i, n in enumerate(indata)))
    outfile.write("};" + "\n")
    outfile.write("#endif" + "\n")

finally:
    infile.close()
    outfile.close()
