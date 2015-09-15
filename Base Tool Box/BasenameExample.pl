
#! /usr/bin/perl
use strict;
use warnings;
use File::Basename;
 
my $fullname = 'C:\Users\Hunter\Documents\Perl\basename.pl';
my @suffixlist = qw(.exe .pl .txt);
my ($name,$path,$suffix) = fileparse($fullname,@suffixlist);
print "name = $name\n";
print "path = $path\n";
print "suffix = $suffix\n";
$name = fileparse($fullname,@suffixlist);
print "name = $name\n";
my $Basename = basename($fullname,@suffixlist);
print "Basename = $Basename\n";
my $dirname = dirname($fullname);
print "dirname = $dirname\n";
