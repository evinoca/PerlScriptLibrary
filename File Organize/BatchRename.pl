use File::stat; 
use File::Copy;
use Cwd;

my $AddValue = 2;

foreach my $file (glob "*.xls")
{
	if ($file=~m/Log_MS(\d)_PL(\d+)(*+))/)
	{
		print "Trace of Mobile $1 Found !"."\n";
		my $value = $2+$AddValue;
		my $name ="Log_MS$1_PL".$value.$3;
		rename("$file","$name");
		
	}
}	
print "done!\n"