#!/usr/bin/env python
# script to automatically transcode a DVD with HandBrakeCLI.
# The main feature of this script is to scan the DVD automatically
# and select titles by duration, e.g. 15-20 (minutes).

# std imports
import os
import sys
# regular expressions
import re
# subprocess stuff
from subprocess import Popen, PIPE
# option parser
from optparse import OptionParser

# some static configs
# path to application
binary = '/Users/iss/bin/HandBrakeCLI'
# the language for the subtitles (iso-639-2)
userlang = 'eng'
# the handbrake preset to use
preset = 'High Profile'

def print_titles( titles ):
  # for debugging - show parsed information
  for title in titles:
    print '#title:',title.number
    print ' duration:',title.duration
    for track in title.tracks:
      print ' audio track:',track.number,'lang:',track.language,'codec:',track.codec,'ch:',track.ch,'coding:',track.coding,'sr:',track.samplerate,'br:',track.bitrate
    for subtitle in title.subtitles:
      print ' subtitle:',subtitle.number,'lang:',subtitle.language,'coding:',subtitle.coding,'format:',subtitle.format


# function to get the title where with the specified language
def find_track_with_lang( lang, tracks ):
  # go through   all tracks
  for track in tracks:
    if track.language == lang:
      return track.number
  # not found track with specified language
  return 0

# class for holding titl structure
class Title:
  def __init__(self):
    self.number    = 0
    self.duration  = 0
    self.tracks    = list(list())
    self.subtitles = list(list())

# audio track
class AudioTrack:
  def __init__(self):
    self.number     = 0
    self.language   = ''
    self.codec      = ''
    self.ch         = 0
    self.coding     = ''
    self.samplerate = 0
    self.bitrate    = 0

# subtitle class
class SubtitleTrack:
  def __init__(self):
    self.number     = 0
    self.language   = ''
    self.coding     = ''
    self.format     = ''

# function to parse duration return duration in minutes
def parse_duration( durationstr):
  # split by ':'
  hhmmss = durationstr.split(':')
  result = float(hhmmss[0])*60.0 + float(hhmmss[1]) + float(hhmmss[2])/60.0
  return result

# parse audio track
def parse_audio_track( line ):
  fields = line.strip().split(' ')
  # remove any commas or parentheses
  fields = [x.strip(',()') for x in fields]

  result = AudioTrack()
  if len(fields) < 9:
    return result
  # fill fields
  result.number     = fields[0]
  result.language   = fields[6]
  result.codec      = fields[2]
  result.ch         = fields[3]
  result.coding     = fields[5]
  result.samplerate = fields[7]
  result.bitrate    = fields[8]

  return result

# parse subtitle track
def parse_subtitle_track( line ):
  fields = line.strip().split(' ')
  # remove any commas or parentheses
  fields = [x.strip(',()') for x in fields]

  result = SubtitleTrack()
  if len(fields) < 5:
    return result
  # fill fields
  result.number    = fields[0]
  result.language  = fields[3]
  result.coding    = fields[2]
  result.format    = x

  return result

# function to parse the information of one title
def parse_title( titlestring ):
  # split by to lines
  lines = titlestring.split('\n')

  # create new title instance
  result = Title()
  # set title number
  result.number = int(lines[0].strip(':'))

  # active is set when entering audio or subtitle tracks
  active = 'none'
  for line in lines[1:]:
    if line[0:3] == '  +':
      active = 'none'
    elif line[0:5] == '    +':
      if active == 'audio':
        result.tracks.append(parse_audio_track(line[5:]))
      elif active == 'subtitle':
        result.subtitles.append(parse_subtitle_track(line[5:]))

    fields = line.strip().split(' ')
    # sanity check
    if len(fields) < 2:
      continue

    # duration
    if fields[1] == "duration:":
      result.duration = parse_duration( fields[2] )
    # audio tracks
    if fields[1] == 'audio' and fields[2] == 'tracks:':
      active = 'audio'
      # parse audio tracks
    # subtitles
    if fields[1] == 'subtitle' and fields[2] == 'tracks:':
      # parse subtitle tracks
      active = 'subtitle'
  return result


print 'Welcome to footbrake.py, the transcoding helper script for handbrake!'
print 'we\'ll first scan the device, to check which titles to fetch'
print 'so let\'s go!'
print

# parse options ######################################################
# create option parser instance
parser = OptionParser()
parser.add_option( "-i", "--device",   dest="device",   help="input device (e.g. /dev/disk4)" )
parser.add_option( "-o", "--outfile",  dest="outfile",  help="output file with substitution support (%d is expanded to title number)" )
parser.add_option( "-d", "--duration", dest="duration", help="range of durations in minutes to rip (e.g. 15-45)", default='60-480' )
parser.add_option( "-x", "--rm-dups",  dest="rmdups",   help="flag to exclude duplicates from transcoding", default=False, action="store_true" )
parser.add_option( "-b", "--base",     dest="base",     help="episode base (for multiple disk episodes: last episode before the first of this disk [0]", default='0' )
(options, args) = parser.parse_args()

# options sanity check
if not (options.device and options.outfile):
  print "Error in parsing command line: not all mandatory parameters given!"
  print "Mandatory parameters: -i/--device and -o/--outfile"
  parser.print_help()
  sys.exit(1)

print 'scanning all titles using input device %s'% (options.device)
# scan dvd (all titles)
p = Popen( ("%s -i %s --scan -t 0"%(binary,options.device)), shell=True,
         bufsize=3*1024*1024, stderr=PIPE, close_fds=True)

rawscan = p.stderr.read()
print 'done'
print

#rawscan = open( 'dvd_scan_result.txt', 'rb' ).read()

# show what we got
#print 'dvd scan result:'
#print rawscan

# get number of titles
m = re.search( r'.*scan: DVD has ([0-9]+) title\(s\).*', rawscan )
ntitles = int(m.group(1))

print 'ntitles:',ntitles

# split by titles
titlestr_vec = rawscan.split( '+ title ' )
titles = list()

for titlestr in titlestr_vec[1:]:
  titles.append( parse_title( titlestr ) )

if options.rmdups == True:
  # now remove redundant titles (having the same duration)
  durations = {}
  todel = list()
  for title in titles:
    if title.duration in durations.keys():
      #print 'duration already given in title',durations[title.duration]
      print 'deleting alleged duplicate title',title.number
      #print 'deleting it'
      todel.append(title.number)
      continue
    # duration not yet registered, add it
    durations[title.duration] = title.number

  # delete bad titles
  clean = list()
  for title in titles:
    if title.number in todel:
      continue
    else:
      clean.append(title)
  # overwrite bad title list
  titles = clean
  print 'done'
  print

# check durations for transcoding
fromto = options.duration.split('-')
fromto = [float(x) for x in fromto]

# go through all all titles and check for matching durations
matches = list()
for title in titles:
  if title.duration >= fromto[0] and title.duration <= fromto[1]:
    print title.number,'matches duration spec by duration',title.duration
    matches.append(title)
# apply new list
titles = matches
print'done'
print

# show list and ask user how to proceed...
print 'titles to encode:'
for title in titles:
  print 'title',title.number,'with duration',title.duration

# ask user to proceed
ans = raw_input("proceed? [Y/n] ")
if not ans.lower() == 'y':
  print 'cancelled!'
  sys.exit(0)

# encoding loop
for no,title in enumerate(titles):
  print 'encoding title',  title.number
  # find audio track for language
  audio_track = find_track_with_lang( userlang, title.tracks )
  # find subtitle track for language
  subtitle_track = find_track_with_lang( userlang, title.subtitles )

  outfilename = options.outfile%(no+int(options.base)+1)
  # create command line
  cmd = '%s -i %s -t %s -o %s -O -e x264 --x264-profile baseline -q 20 -a %s,%s, -E ca_aac,copy -B 160,160 -6 stereo,6ch --decomb -s %s '%(binary,options.device,title.number,outfilename,audio_track,audio_track,subtitle_track)
  #print 'calling:',cmd
  p = Popen( cmd, shell=True, bufsize=3*1024*1024, stderr=PIPE, close_fds=True)

  hb_stdout = p.stderr.read()
#print_titles( titles )
print 'finished'

if os.uname()[0] == 'Darwin':
  p = Popen( 'diskutil eject %s'%(options.device), bufsize=1024, shell=True, close_fds=True )
  print 'and ejected!'
elif os.uname()[0] == 'Linux':
  p = Popen( 'eject', bufsize=1024, shell=True, close_fds=True )
  print 'and ejected!'
