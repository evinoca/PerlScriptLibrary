foreach my $i (0..1000)
{
 next unless $i%5;                      # next if this number is a multiple of 5
 print "$i is not a multiple of 5...\n";
 next unless $i%7;                      # next if this number is a multiple of 7
 print "$i is not a multiple of 7...\n";
 next unless $i%12;                     # next is this number is a multiple of 12
 # $i is now not a multiple of 12, 5, or 7
 print "$i is a lucky, lucky number to have met you...\n";
}