#!/usr/bin/Perl
use strict;
use warnings;


my $number = 2;
my @array3 = (10,12,1,0,4,3,13,14,6,5,2);
my $flag = 0;
print "Number : $number\n";
print "Original: @array3\n";
my @sortedNumerically = sort { $a <=> $b } @array3;
print "Numerically: @sortedNumerically\n";
map { if($number eq $_) { print "here$number\n" ; $number= $_+1 ; $flag = 1} } @sortedNumerically;
print "Number : $number\n";