use strict;
use File::stat; 
use File::Copy;
use Cwd;

my $Source = "C:\\QXDM\\SWR";
my $tofolder = $ARGV[0]

mkdir $Source unless (-e $Source);
mkdir $tofolder unless (-e $tofolder);

chdir($Source) or die "Can't cd dir: Source!\n" ;
foreach my $file (glob "*.isf")
{
	print "->   $file\n";
	copy($file,$tofolder)
		
}
