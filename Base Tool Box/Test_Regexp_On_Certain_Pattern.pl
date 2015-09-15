
use strict;

my $counter = 1;
my $flag = "true";
my @arry=();

foreach my $file (glob "*.txt")
{
	if ($file =~ /url.*\.txt/)
	{
		open (Buffer,$file) or die "$!";
		while (<Buffer>)
		{
			while (1)
			{
				print "\n";

				if ($_ = ~m/([\w|\.]+\@[\w+|\S+]+)+(.*)/)
				{
					my $len = rindex $1."\$", "\$"; 
								
					if ($len == 0 )
					{
						last;
					}
					print "Match Number $counter:  ".$1."\n";
					push @arry,$1;
					print "Remain:  ".$2."\n";
					$counter+=1;
					$_ = $2;
					print '$_ = '.$_."\n";
					print 'phase 2 The Length of String is '.length;
					print "\n";
					
					if (length == 0 )
					{
						last;
					}
				}
				else
				{
					$flag = "false";
					print "No Match found...\n";
				}
							}
		}
	}	
}
print "\n***********************************************************\n";
print "@arry\n";

