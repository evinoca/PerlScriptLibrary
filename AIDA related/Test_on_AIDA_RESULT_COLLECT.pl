use strict;
use File::Copy;

my $workspace = "C:\\workspace";
my $path_local_base = 'S:\\bakup';
my $path_local_storage =  'S:\\';
my $path_remote_storage =  'T:\\';
my $i = 110;
print "Start here\n";
my $testTimes = 120;

if ($ARGV[0 == "debug"])
{
	while ($i <= $testTimes)
	{
		print "Pathlose now equals $i \n";
		chdir($path_local_base)or die "Can't cd dir: $!\n" ;
		foreach my $file (glob "*.bak")
		{
			print "$file\n";
			print "Copy files to local folder\n";
			copy($file,$path_local_storage."\\".$file);
			print "Copy files to Remote folder\n";
			copy($file,$path_remote_storage."\\".$file);
		}
		$i+=1;
		my $p1 = $i -100;
		my $p2 = $i - 99;
		my $p3 = $i - 98;
		chdir($workspace);
		system("perl AIDA_Result_Collect.pl AIDA_SMOKE_DOWNLOAD_TEST_ON_RPI_SCRIPT $i $p2 4");

	}
	my $i = 110;
	print "Down load Scenarios Finished\n";
	while ($i <= $testTimes)
	{
		print "Pathlose now equals $i \n";
		chdir($path_local_base)or die "Can't cd dir: $!\n" ;
		foreach my $file (glob "*.bak")
		{
			print "$file\n";
			print "Copy files to local folder\n";
			copy($file,$path_local_storage."\\".$file);
			print "Copy files to Remote folder\n";
			copy($file,$path_remote_storage."\\".$file);
		}
		$i+=1;
		my $p1 = $i -100;
		my $p2 = $i - 99;
		my $p3 = $i - 98;
		chdir($workspace);
		system("perl AIDA_Result_Collect.pl AIDA_SMOKE_UPLOAD_TEST_ON_RPI_SCRIPT $i $p1;$p2;$p3 4");
	}
	print "Up load Scenarios Finished\n";
}
else 
{
	chdir($path_local_base)or die "Can't cd dir: $!\n" ;
		foreach my $file (glob "*.bak")
		{
			print "$file\n";
			print "Copy files to local folder\n";
			copy($file,$path_local_storage."\\".$file);
			print "Copy files to Remote folder\n";
			copy($file,$path_remote_storage."\\".$file);
		}
}