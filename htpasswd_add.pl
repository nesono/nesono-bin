#!/usr/bin/env perl
use strict;

chomp(my $filename=$ARGV[0]);
chomp(my $username=$ARGV[1]);
chomp(my $password=$ARGV[2]);

if (!$filename || !$username || !$password) {
  print "USAGE: ./crypt.pl filename username password\n\n";
} else {
  open my $fh, ">>", $filename or die $!;
  print $fh $username . ":" . crypt($password, $username) . "\n";
  close $fh or die $!;
}
